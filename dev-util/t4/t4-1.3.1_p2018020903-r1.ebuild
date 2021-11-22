# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit dotnet mono-pkg-config

GITHUB_ACCOUNT="mono"
GITHUB_PROJECTNAME="t4"
EGIT_COMMIT="0a1424821b493704b4e8ecaee8f6378b8893c0c8"
HOMEPAGE="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

COMMON_DEPEND="
	>=dev-dotnet/mono-options-5.11.0.132
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply_user
}

src_compile() {
	mkdir -p "Mono.TextTemplating/Mono.TextTemplating/bin/$(usedebug_tostring)" || die
	csc /unsafe /recurse:Mono.TextTemplating/*.cs  -t:library -out:"Mono.TextTemplating/Mono.TextTemplating/bin/$(usedebug_tostring)/Mono.TextTemplating.dll" || die
	mkdir -p "TextTransform/bin/$(usedebug_tostring)" || die
	csc  -t:exe -out:"TextTransform/bin/$(usedebug_tostring)/TextTransform.exe" \
		-r:Mono.TextTemplating/Mono.TextTemplating/bin/$(usedebug_tostring)/Mono.TextTemplating.dll \
		-r:/usr/share/dev-dotnet/mono-options/Mono.Options.dll \
		TextTransform/TextTransform.cs || die
}

src_install() {
	elib "Mono.TextTemplating/Mono.TextTemplating/bin/$(usedebug_tostring)/Mono.TextTemplating.dll"

	local INSTALL_PATH="/usr/share/${PN}/slot-${SLOT}"

	insinto "${INSTALL_PATH}"
	doins "TextTransform/bin/$(usedebug_tostring)/TextTransform.exe"

	dosym "/usr/share/dev-dotnet/${PN}/Mono.TextTemplating.dll" "${INSTALL_PATH}/Mono.TextTemplating.dll"
	dosym "/usr/share/dev-dotnet/mono-options/Mono.Options.dll" "${INSTALL_PATH}/Mono.Options.dll"

	make_wrapper t4 "/usr/bin/mono ${INSTALL_PATH}/TextTransform.exe"
}
