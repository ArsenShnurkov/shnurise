# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

DESCRIPTION="The C# port of ANTLR 3"
LICENSE="BSD"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug source"

inherit dotnet

HOMEPAGE="https://github.com/ArsenShnurkov/acme.net"
GITHUB_ACCOUNT="ArsenShnurkov"
GITHUB_REPONAME="acme.net"
EGIT_COMMIT="97e7b1a1c44b6b4505b7b56de9594e2709fe1fd0"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

DESCRIPTION="The C# port of ANTLR 3"
LICENSE="MIT"

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
	:;
}

src_install() {
	:;
}
