# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8" # valid EAPI assignment must occur on or before line: 5

KEYWORDS="amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit dotnet

GITHUB_ACCOUNT="dotnet"
GITHUB_REPONAME="roslyn-tools"
EGIT_COMMIT="8a1c2507afd04904cfa34515509f264b87655494"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

LICENSE="Apache-2.0" # https://github.com/dotnet/roslyn-tools/blob/master/LICENSE.md

HOMEPAGE="https://github.com/dotnet/roslyn-tools"
DESCRIPTION="'Tools used in Roslyn based repos "

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply_user
}

src_compile() {
	default
}

src_install() {
	default
}

