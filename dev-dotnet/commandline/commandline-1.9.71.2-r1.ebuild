# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8" # valid EAPI assignment must occur on or before line: 5

KEYWORDS="amd64"
RESTRICT+=" mirror"

SLOT="0"

GITHUB_ACCOUNT="commandlineparser"
GITHUB_REPONAME="commandline"
REPOSITORY="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}"

HOMEPAGE="https://github.com/commandlineparser/commandline"
DESCRIPTION="C# (and F#) command line parser with standardized *nix getopt style"
LICENSE="MIT"

COMMON_DEPEND=">=dev-lang/mono-6
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config debug developer"

inherit msbuild # allows to build .csproj files
inherit mono-pkg-config # mono-pkg-config allows to install .pc-files for monodevelop

EGIT_COMMIT="205094c0c135ab5b6816f3eb0e6a84ddced5b0e2"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

RESTRICT+=" test"

src_prepare() {
	eapply_user
}

src_compile() {
	emsbuild src/libcmdline/CommandLine.csproj
}

src_install() {
	:;
}
