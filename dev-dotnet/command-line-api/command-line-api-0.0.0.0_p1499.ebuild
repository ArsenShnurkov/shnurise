# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6" # valid EAPI assignment must occur on or before line: 5

#KEYWORDS="~amd64 ~x86"
KEYWORDS="~amd64 ~x86 ~ppc"
RESTRICT="mirror"

SLOT="0"

HOMEPAGE="https://github.com/dotnet/command-line-api"
DESCRIPTION="Library for building command line applications with extensible middleware pipeline"


inherit dotnet

GITHUB_ACCOUNT="dotnet"
GITHUB_REPONAME="command-line-api"
EGIT_COMMIT="0c8d7fea8bf5f3e8eefa1e1040accaf2a1117b2b"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

LICENSE="MIT" # https://github.com/dotnet/command-line-api/blob/master/LICENSE.md

HOMEPAGE="https://github.com/dotnet/command-line-api"
DESCRIPTION="Library for building command line applications with extensible middleware pipeline"

COMMON_DEPEND=">=dev-lang/mono-6
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply_user
}

src_compile() {
	cd "${S}/src/System.CommandLine" || die
	mkdir -p bin/Release || die
	/usr/bin/csc \
		-r:System.dll -r:Microsoft.CSharp.dll -r:System.Core.dll \
		/langversion:8.0 \
		*.cs \
		**/*.cs \
		/t:library /out:bin/Release/System.CommandLine.dll || die
}

src_install() {
	default
}

