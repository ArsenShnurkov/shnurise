# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="0"

KEYWORDS="amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
USE_MSBUILD="msbuild15-9"

# inherit directive is placed before IUSE line because of dotnet_expand and msbuild_expand functions

inherit msbuild-framework
inherit xbuild gac

NAME="roslyn"
HOMEPAGE="https://github.com/dotnet/${NAME}"
EGIT_COMMIT="ec1cde8b77c7bca654888681037f55aa0e62dd19"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${NAME}-${PV}.tar.gz
	mskey? ( https://github.com/Microsoft/msbuild/raw/master/src/MSFT.snk )
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="C# compiler with rich code analysis APIs"
LICENSE="Apache2.0" # https://github.com/dotnet/roslyn/blob/master/License.txt

IUSE="$(dotnet_expand ${USE_DOTNET}) $(msbuild_expand ${USE_MSBUILD}) +msbuild +gac +mskey +debug developer"

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


METAFILE_FO_BUILD="${S}/src/Compilers/Core/MSBuildTask/mono-MSBuildTask.csproj"

function output_filename ( ) {
	echo "src/Compilers/Core/MSBuildTask/bin/$(usedebug_tostring)/${TargetVersion}/Microsoft.Build.Tasks.CodeAnalysis.dll"
}

src_prepare() {
	cp "${FILESDIR}/mono-MSBuildTask.csproj" "${METAFILE_FO_BUILD}" || die
	eapply_user
}

src_compile() {
	if use msbuild; then
		local targets=( ${USE_MSBUILD} )
		for target in ${targets[@]}; do
		local etarget="$( msbuild_expand ${target} )"
		if use ${etarget}; then
			local TARGET_SLOT=${target//msbuild/}
			TargetVersion=${TARGET_SLOT//-/.}
			exbuild "/p:TargetFrameworkVersion=v4.6" "/p:VersionNumber=${TargetVersion}.0.0" "/p:TargetVersion=${TargetVersion}" "/p:ReferencesVersion=${TargetVersion}.0.0" "/p:PublicKeyToken=$(token)" "/p:SignAssembly=true" "/p:DelaySign=true" "/p:AssemblyOriginatorKeyFile=$(token_key)" "${METAFILE_FO_BUILD}"
			sn -R "${S}/$(output_filename)" "$(signing_key)" || die
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
			#TargetVersion=${TARGET_SLOT//-/.}
			TargetVersion=$(ver_cut 1 ${TARGET_SLOT}).0
			insinto "/usr/share/msbuild/${MSBuildToolsVersion}/Roslyn/"
			doins "${S}/src/Compilers/Core/MSBuildTask/Microsoft.CSharp.Core.targets"
			doins "${S}/src/Compilers/Core/MSBuildTask/Microsoft.VisualBasic.Core.targets"
			doins "${S}/$(output_filename)"
		 	if use gac; then
				egacinstall "${S}/$(output_filename)"
			fi
               fi
	    done
	fi 
}

