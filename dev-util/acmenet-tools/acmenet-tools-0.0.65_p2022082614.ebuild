# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="amd64 arm64"
RESTRICT="mirror"

SLOT="0"

DESCRIPTION="Console utility for requesting certificates"
HOMEPAGE="https://github.com/ArsenShnurkov/acme.net"
LICENSE="MIT"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} pkg-config debug developer source"

inherit dotnet msbuild mono-pkg-config gentoo-net-sdk

GITHUB_ACCOUNT="ArsenShnurkov"
GITHUB_REPONAME="acme.net"
EGIT_COMMIT="8e03587bc84a41d55b6a2466150ff04685a20df3"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	gentoo-net-sdk_src_prepare
	default
}

src_compile() {
	emsbuild "src/Oocx.Acme/Oocx.Acme.csproj"
	emsbuild "src/Oocx.Acme.Console/Oocx.Acme.Console.csproj"
}

src_install() {
	:;
}
