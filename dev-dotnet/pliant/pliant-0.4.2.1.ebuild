# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac +nupkg developer debug doc"

inherit gac dotnet nupkg

NAME="Pliant"
HOMEPAGE="https://github.com/patrickhuber/${NAME}"
EGIT_COMMIT="7a4b3a2c8d9416092293480464d502be7e0323e5"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="modified Earley parser in C# inspired by the Marpa Parser project"
LICENSE="MIT" # https://github.com/patrickhuber/Pliant/blob/master/LICENSE.md

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	patch_nuspec_file "libraries/Pliant/Pliant.nuspec"
	eapply_user
}

NUSPEC_VERSION=${PV}

get_bin_dir()
{
	echo "libraries/Pliant/bin"
}

get_output_dir()
{
	local OUTPUT_DIR="$(get_bin_dir)/"
	if use debug; then
		OUTPUT_DIR+="Debug"
	else
		OUTPUT_DIR+="Release"
	fi
	echo "${OUTPUT_DIR}"
}

DLL_NAME="${NAME}"

get_output_filepath()
{
	echo "$(get_output_dir)/${DLL_NAME}.dll"
}

patch_nuspec_file()
{
	if use nupkg; then
		FILES_STRING=`sed 's/[\/&]/\\\\&/g' <<-EOF || die "escaping replacement string characters"
		  <files> <!-- https://docs.nuget.org/create/nuspec-reference -->
		    <file src="$(get_output_dir)/${DLL_NAME}.*" target="lib/net45/" />
		  </files>
		EOF
		`
		sed -i 's/<\/package>/'"${FILES_STRING//$'\n'/\\$'\n'}"'\n&/g' $1 || die "escaping line endings"
	fi
}

src_compile() {
	exbuild_strong "libraries/Pliant/Pliant.csproj"
	NUSPEC_VERSION="${PV/_p/.}"
	NUSPEC_PROPERTIES="id=${NAME};version=${NUSPEC_VERSION};author=Patrick Huber;description=${DESCRIPTION}"
	enuspec "libraries/Pliant/Pliant.nuspec"
}

src_install() {
	egacinstall "$(get_output_filepath)"
	einstall_pc_file "${PN}" "${PV}" "Pliant"
	enupkg "${WORKDIR}/${NAME}.${NUSPEC_VERSION}.nupkg"
}
