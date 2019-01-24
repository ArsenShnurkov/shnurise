# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
SLOT="0"

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit versionator dotnet

GITHUB_REPONAME="sdk"
GITHUB_ACCOUNT="dotnet"
EGIT_COMMIT="4908e1f6d532cb823b6889816c49fb5134b0278c"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"

LICENSE="MIT" # https://github.com/dotnet/sdk/blob/master/LICENSE.TXT

HOMEPAGE="https://github.com/dotnet/sdk/"
#DESCRIPTION="Core functionality needed to create .NET Core projects, that is shared between Visual Studio and CLI"
DESCRIPTION="'Microsoft.NET.Sdk' for msbuild"

S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

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
