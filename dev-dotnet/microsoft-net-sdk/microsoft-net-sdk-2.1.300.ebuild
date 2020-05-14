# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="0"

KEYWORDS="amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
USE_MSBUILD="msbuild15-9 msbuild15-7 msbuild15-4"

# inherit directive is placed before IUSE line because of dotnet_expand and msbuild_expand functions
inherit dotnet msbuild-framework

IUSE="$(dotnet_expand ${USE_DOTNET}) $(msbuild_expand ${USE_MSBUILD}) +msbuild"

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
	if use msbuild; then
	    local targets=( ${USE_MSBUILD} )
	    for target in ${targets[@]}; do
		local etarget="$( msbuild_expand ${target} )"
		if use ${etarget}; then
			local TARGET_SLOT=${target//msbuild/}
			#MSBuildToolsVersion=${TARGET_SLOT//-/.}
			# /usr/share/msbuild/15.9/bin/Sdks/Microsoft.NET.Sdk/Sdk
			MSBuildToolsVersion=$(ver_cut 1 $TARGET_SLOT).0
			insinto /usr/share/msbuild/${MSBuildToolsVersion}/bin/Sdks/Microsoft.NET.Sdk/sdk
			doins -r "${S}"/src/Tasks/Microsoft.NET.Build.Tasks/sdk/*
			insinto /usr/share/msbuild/${MSBuildToolsVersion}/bin/Sdks/Microsoft.NET.Sdk/targets
			doins -r "${S}"/src/Tasks/Microsoft.NET.Build.Tasks/targets/*
                fi
	    done
	fi 
}

