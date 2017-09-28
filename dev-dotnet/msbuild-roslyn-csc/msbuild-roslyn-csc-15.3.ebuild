# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"

inherit dotnet gac

NAME="roslyn"
HOMEPAGE="https://github.com/dotnet/${NAME}"
EGIT_COMMIT="ec1cde8b77c7bca654888681037f55aa0e62dd19"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${NAME}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="C# compiler with rich code analysis APIs"
LICENSE="Apache2.0" # https://github.com/dotnet/roslyn/blob/master/License.txt

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
	dev-dotnet/msbuild-tasks-api developer? ( dev-dotnet/msbuild-tasks-api[developer] )
	dev-dotnet/msbuild-defaulttasks developer? ( dev-dotnet/msbuild-defaulttasks[developer] )
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/msbuildtasks
"

KEY2="${DISTDIR}/mono.snk"

METAFILE_FO_BUILD="${S}/src/Compilers/Core/MSBuildTask/mono-MSBuildTask.csproj"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "Source/MSBuild.Community.Tasks/bin/${DIR}/MSBuild.Community.Tasks.dll"
}

src_prepare() {
	cp "${FILESDIR}/MSBuildTask.csproj" "${METAFILE_FO_BUILD}" || die
	eapply_user
}

src_compile() {
	exbuild "${METAFILE_FO_BUILD}"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	insinto "/usr/share/msbuild/Roslyn"
	doins "${S}/src/Compilers/Core/MSBuildTask/Microsoft.CSharp.Core.targets"
	doins "${S}/src/Compilers/Core/MSBuildTask/Microsoft.VisualBasic.Core.targets"
	egacinstall "$(output_filename)"
}
