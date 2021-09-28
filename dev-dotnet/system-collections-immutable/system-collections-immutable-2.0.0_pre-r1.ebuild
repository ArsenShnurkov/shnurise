# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
RESTRICT="mirror"
KEYWORDS="amd64 arm64"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac pkg-config developer debug doc"

inherit xbuild gac mono-pkg-config

GITHUB_ACCOUNT="dotnet"
GITHUB_PROJECTNAME="corefx"
EGIT_COMMIT="247068fbd97c534dc13b3b9d037f67b03dbe57a5"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/dotnet/corefx/tree/master/src/System.Collections.Immutable"
DESCRIPTION="part of CoreFX"
LICENSE="MIT" # https://github.com/dotnet/corefx/blob/master/LICENSE.TXT

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

PROJ1=System.Collections.Immutable
PROJ1_DIR=src/${PROJ1}/src

src_prepare() {
	cp "${FILESDIR}/mono-${PROJ1}-r1.csproj" "${S}/${PROJ1_DIR}/mono-${PROJ1}.csproj" || die
	cp "${FILESDIR}/SR.cs" "${S}/${PROJ1_DIR}/SR.cs" || die
	cp "${FILESDIR}/AV.cs" "${S}/${PROJ1_DIR}/AV.cs" || die
	eapply_user
}

src_compile() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	if use developer; then
		SARGS=DebugSymbols=True
	else
		SARGS=DebugSymbols=False
	fi

	VER=2.0.0.0
	KEY="${FILESDIR}/mono.snk"

	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${PROJ1_DIR}/mono-${PROJ1}.csproj"
	sn -R "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll" "${KEY}" || die
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	egacinstall "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll"
	# einstall_pc_file "System.Collections.Immutable" "${PV}" '${libdir}'"/mono/${PN}/${PROJ1}.dll"
	einstall_pc_file "System.Collections.Immutable" "${PV}" '/usr/lib/mono/'"${PN}"'/'"${PROJ1}"'.dll'
}
