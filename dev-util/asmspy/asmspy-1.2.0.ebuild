# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer"

inherit eutils xbuild

GITHUB_ACCOUNT="mikehadlow"
GITHUB_REPONAME="AsmSpy"
HOMEPAGE="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}"
EGIT_COMMIT="854751d9f624d1e054d658856aca67b49f82ed0f"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

DESCRIPTION="Simple command line assembly reference checker"
LICENSE="MIT" # https://github.com/mikehadlow/AsmSpy/blob/master/licence.txt

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply_user
}

src_compile() {
	exbuild "${S}/AsmSpy/AsmSpy.csproj"
}

INSTALL_DIR="/usr/share/${PN}${APPENDIX}"

src_install() {
	insinto "${ED}/${INSTALL_DIR}"
	doins -r "${S}/${OUTPUT_PATH}"

	if use debug; then
		make_wrapper asmspy "/usr/bin/mono --debug \${MONO_OPTIONS} ${INSTALL_DIR}/AsmSpy.exe"
	else
		make_wrapper asmspy "/usr/bin/mono \${MONO_OPTIONS} ${INSTALL_DIR}/AsmSpy.exe"
	fi
}

