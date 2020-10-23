# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="0"

KEYWORDS="amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
USE_MSBUILD="msbuild15-9 msbuild15-7 msbuild15-4"

# These two inherit directives are placed before IUSE line because of dotnet_expand and msbuild_expand functions
inherit dotnet
inherit msbuild-framework

IUSE="+$(dotnet_expand ${USE_DOTNET}) $(msbuild_expand ${USE_MSBUILD}) +msbuild debug developer"

inherit dotbuildtask

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
			MSBUILD_TARGET="${target}"
			einfo src_install: MSBUILD_TARGET="${MSBUILD_TARGET}"

			#insinto $(MSBuildSdksPath)/Microsoft.NET.Sdk/sdk
			#doins -r "${S}"/src/Tasks/Microsoft.NET.Build.Tasks/sdk/*
			einssdk "Microsoft.NET.Sdk" \
				"${S}"/src/Tasks/Microsoft.NET.Build.Tasks/sdk/*.props \
				"${S}"/src/Tasks/Microsoft.NET.Build.Tasks/sdk/*.targets
			insinto $(MSBuildSdksPath)/Microsoft.NET.Sdk/targets
			doins "${S}"/src/Tasks/Microsoft.NET.Build.Tasks/targets/*.props
			doins "${S}"/src/Tasks/Microsoft.NET.Build.Tasks/targets/*.targets
			# doins "${S}"/src/Tasks/Common/targets/*.props # - no such files
			doins "${S}"/src/Tasks/Common/targets/*.targets
			#einstask "${S}"/src/Tasks/Microsoft.NET.Build.Tasks/bin/$(usedebug_tostring)/*
                fi
	    done
	fi 
}

