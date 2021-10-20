# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="0"
KEYWORDS="amd64 arm64"
RESTRICT="mirror test"

# These two inherit directives are placed before IUSE line because of dotnet_expand and msbuild_expand functions
inherit dotnet
inherit msbuild-framework

USE_DOTNET="net45"
USE_MSBUILD="msbuild15-9 msbuild15-7 msbuild15-4"
IUSE="+$(dotnet_expand ${USE_DOTNET}) +$(msbuild_expand ${USE_MSBUILD}) +msbuild debug developer"

inherit dotbuildtask

# see https://devmanual.gentoo.org/general-concepts/dependencies/
# «Starting with EAPI 7, build dependencies are split into two variables: BDEPEND and DEPEND.
# BDEPEND specifies dependencies applicable to CBUILD, i.e. programs that need to be executed during the build.
# DEPEND specifies dependencies for CHOST, i.e. packages that need to be found on built system, e.g. libraries and headers.
# In earlier EAPIs, all build dependencies are placed in DEPEND.»
# The RDEPEND ebuild variable should specify any dependencies which are required at runtime.
# This includes libraries (when dynamically linked), any data packages and (for interpreted languages) the relevant interpreter.
# Note that when installing from a binary package, only RDEPEND will be checked.

DEPEND="
	dev-dotnet/msbuild-tasks-api:15.9
"

RDEPEND="
	${DEPEND}
"

HOMEPAGE="https://github.com/ArsenShnurkov/mono-packaging-tools"
DESCRIPTION="Alternative build sequence with PkgConfig instead of NuGet"
LICENSE="GPL-3"

EGIT_COMMIT="53302a0f624c7e9918208713ad5d1ca002a6ccba"
GITHUB_PROJECTNAME="mono-packaging-tools"
GITHUB_ACCOUNT="ArsenShnurkov"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

function references() {
	echo -n \
		$(reference_dependency Microsoft.Build.Framework-15.9) \
		$(reference_framework System)
}

src_compile() {
	mkdir -p $(bin_dir) || die
	ecsc $(references) $(csharp_sources Gentoo.NET.Sdk/Gentoo.NET.Sdk.Tasks) $(output_dll Gentoo.NET.Sdk.Tasks)
}

src_install () {
	if use msbuild; then
	    local targets=( ${USE_MSBUILD} )
	    for target in ${targets[@]}; do
		local etarget="$( msbuild_expand ${target} )"
		if use ${etarget}; then
			local TARGET_SLOT=${target//msbuild/}
			MSBUILD_TARGET="${target}"
			einssdk "Gentoo.NET.Sdk" \
				"${S}/Gentoo.NET.Sdk/Sdk/Sdk.props" \
				"${S}/Gentoo.NET.Sdk/Sdk/Sdk.targets"
			einstask "$(bin_dir)/Gentoo.NET.Sdk.Tasks.dll"
                fi
	    done
	fi 
}
