# Copyright 1999-2021 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="0"

KEYWORDS="amd64 arm64"
RESTRICT="mirror"

USE_DOTNET="net45"
USE_MSBUILD="msbuild15-9"

# inherit directive is placed before IUSE line because of dotnet_expand and msbuild_expand functions

inherit msbuild-framework
inherit xbuild gac
inherit vcs-snapshot

IUSE="$(dotnet_expand ${USE_DOTNET}) $(msbuild_expand ${USE_MSBUILD}) +msbuild +debug developer"

NAME="roslyn"
HOMEPAGE="https://github.com/dotnet/${NAME}"
EGIT_COMMIT="ec1cde8b77c7bca654888681037f55aa0e62dd19"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${NAME}-${PV}.tar.gz"

S="${WORKDIR}/roslyn-${PV}"

DESCRIPTION="C# compiler with rich code analysis APIs"
LICENSE="MIT" # https://github.com/dotnet/roslyn/blob/master/License.txt

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
	msbuild_targets_msbuild15-9? (
		dev-dotnet/msbuild-tasks-api:15.9
		dev-dotnet/msbuild-defaulttasks:15.9
	)
"

RDEPEND="${COMMON_DEPEND}
"

DEPEND="${COMMON_DEPEND}
"
# BDEPEND
# dev-dotnet/msbuildtasks

src_prepare() {
	if ! use msbuild_targets_msbuild15-9 ; then
		die "USE_MSBUILD is not set"
	fi
	eapply "${FILESDIR}/99-CopyRefAssemblyFix.patch"
	eapply "${FILESDIR}/csc-name.patch"
	eapply_user
}

src_resources() {
	local OUTNAME=""
	OUTNAME=ErrorString.resources
	eresgen "ErrorString.resx" "${OUTNAME}"
	echo -n ' -resource:"'${OUTNAME}'" '
}

SOURCES=(
"../../Shared/BuildServerConnection.cs"
"../CommandLine/BuildProtocol.cs"
"../CommandLine/ConsoleUtil.cs"
"../CommandLine/NativeMethods.cs"
"../CommandLine/CompilerServerLogger.cs"
"../Portable/CorLightup.cs"
"../Portable/InternalUtilities/CommandLineUtilities.cs"
"../Portable/InternalUtilities/CompilerOptionParseUtilities.cs"
"../Portable/InternalUtilities/IReadOnlySet.cs"
"../Portable/InternalUtilities/PlatformInformation.cs"
"../Portable/InternalUtilities/ReflectionUtilities.cs"
"../Portable/InternalUtilities/UnicodeCharacterUtilities.cs"
"AssemblyResolution.cs"
"CanonicalError.cs"
"MvidReader.cs"
"CopyRefAssembly.cs"
"ValidateBootstrap.cs"
"CommandLineBuilderExtension.cs"
"Csc.cs"
"Csi.cs"
"ErrorString.Designer.cs"
"ICompilerOptionsHostObject.cs"
"ICscHostObject5.cs"
"InteractiveCompiler.cs"
"IVbcHostObject6.cs"
"ManagedCompiler.cs"
"PropertyDictionary.cs"
"RCWForCurrentContext.cs"
"Utilities.cs"
"Vbc.cs"
)

src_references() {
 echo -n " $(reference_dependency Microsoft.Build.Framework-15.9) "
 echo -n " $(reference_dependency Microsoft.Build.Tasks-15.9) "
}

src_compile_one_target()
{
	cd "${S}/src/Compilers/Core/MSBuildTask" || die
	mkdir -p "$(bin_dir)/${MSBUILD_TARGET}" || die

	local RESOURCES="$(src_resources)"
	einfo RESOURCES="${RESOURCES}"
	local REFERENCES="$(src_references)"
	einfo REFERENCES="${REFERENCES}"
	ecsc ${RESOURCES} ${REFERENCES} "${SOURCES[@]}" $(output_dll "${MSBUILD_TARGET}/Microsoft.Build.Tasks.CodeAnalysis")

	return 0;
}

src_install_one_target()
{
	local OUTPUT_FILENAME="$(bin_dir)/${MSBUILD_TARGET}/Microsoft.Build.Tasks.CodeAnalysis.dll"
	insinto "$(RoslynTargetsPath)"
	doins "${S}/src/Compilers/Core/MSBuildTask/Microsoft.CSharp.Core.targets"
	doins "${S}/src/Compilers/Core/MSBuildTask/Microsoft.VisualBasic.Core.targets"
	doins "${OUTPUT_FILENAME}"
	if use gac; then
		egacinstall "${OUTPUT_FILENAME}"
	fi
	return 0;
}

src_compile() {
    if use msbuild; then
        local targets=( ${USE_MSBUILD} )
        for target in ${targets[@]}; do
            local etarget="$( msbuild_expand ${target} )"
            if use ${etarget}; then
                local TARGET_SLOT=${target//msbuild/}
                MSBUILD_TARGET=${TARGET_SLOT//-/.}
                src_compile_one_target "${MSBUILD_TARGET}" || die
            fi
        done
    fi
}

src_install() {
	if use msbuild; then
	    local targets=( ${USE_MSBUILD} )
	    for target in ${targets[@]}; do
		local etarget="$( msbuild_expand ${target} )"
		if use ${etarget}; then
			local TARGET_SLOT=${target//msbuild/}
			MSBUILD_TARGET=${TARGET_SLOT//-/.}
			src_install_one_target "${MSBUILD_TARGET}" || die
               fi
	    done
	fi 
}
