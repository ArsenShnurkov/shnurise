# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
SLOT="0"

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

USE_DOTNET="net45"

# inherit directive is placed before IUSE line because of dotnet_expand and msbuild_expand functions
inherit dotnet msbuild-framework

IUSE="$(dotnet_expand ${USE_DOTNET}) +msbuild"

GITHUB_REPONAME="sdk"
GITHUB_ACCOUNT="dotnet"
EGIT_COMMIT="4908e1f6d532cb823b6889816c49fb5134b0278c"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

LICENSE="MIT" # https://github.com/dotnet/sdk/blob/master/LICENSE.TXT

HOMEPAGE="https://github.com/dotnet/sdk/"
#DESCRIPTION="Core functionality needed to create .NET Core projects, that is shared between Visual Studio and CLI"
DESCRIPTION="'Microsoft.NET.Sdk' for msbuild"

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
	insinto /usr/share/msbuild/Sdks/Microsoft.NET.Sdk/Sdk
	doins -r "${S}"/src/Tasks/Microsoft.NET.Build.Tasks/sdk/*
	insinto /usr/share/msbuild/Sdks/Microsoft.NET.Sdk/Targets
	doins -r "${S}"/src/Tasks/Microsoft.NET.Build.Tasks/targets/*
}

