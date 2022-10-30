# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="amd64 arm64"
RESTRICT="mirror"

SLOT="13"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config debug source"

inherit dotnet mono-pkg-config

EGIT_COMMIT="080d4131ccb8f202aea543b46e861488e906ac8a"

NAME="DotNetZip.Semverd"
HOMEPAGE="https://github.com/haf/DotNetZip.Semverd"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="create, extract, or update zip files with C# (=DotNetZip+SemVer)"
LICENSE="Ms-PL" # https://github.com/haf/DotNetZip.Semverd/blob/master/LICENSE

COMMON_DEPEND="
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

function bin_dir ( ) {
	echo "${WORKDIR}/$(output_relpath)"
}

function references1() {
	echo -n " " /reference:System.dll
}

function sources1() {
	echo -n " " $(csharp_sources "${S}/src/Zip_Reduced")
	echo -n " " $(csharp_sources "${S}/src/BZip2")
	echo -n " " $(csharp_sources "${S}/src/Zip.Shared")
	echo -n " " $(csharp_sources "${S}/src/Zlib.Shared")
	echo -n " " "${S}/src/SolutionInfo.cs"
}

SRC_INSTALL_DIR=/usr/src/dev-dotnet/dotnetzip-semverd

function output_arguments1 ( ) {
	#output type and name
	local OUTPUT_TYPE="library" # https://docs.microsoft.com/ru-ru/dotnet/csharp/language-reference/compiler-options/target-exe-compiler-option
	echo  "/target:${OUTPUT_TYPE}" "/out:$(output_filename1)"

	# for reproducible builds
	echo -n " " -deterministic

	# debug information options
	if use debug; then
		echo -n " " /debug:full
		echo -n " " /pdb:$(bin_dir)/Ionic.Zip.Reduced.pdb

		# options for source-level debugging
		echo -n " " /pathmap:path1=${S},path2=${SRC_INSTALL_DIR}
	fi
}

function output_filename1( ) {
	echo "$(bin_dir)/Ionic.Zip.Reduced.dll"
}

src_prepare() {
	rm "${S}/src/BZip2/Properties/AssemblyInfo.cs" || die
	mv "${S}/src/Zip Reduced" "${S}/src/Zip_Reduced" || die
	eapply_user
}

src_compile() {
	mkdir -p $(bin_dir) || die
	einfo /usr/bin/csc $(references1) $(sources1) $(output_arguments1)
	/usr/bin/csc $(references1) $(sources1) $(output_arguments1) || die
}

src_install() {
	einfo "$(output_filename1)"
	local INSTALL_DIR="$(anycpu_current_assembly_dir)"
	elib2 ${INSTALL_DIR} "$(output_filename1)"
#	einstall_pc_file "Ionic.Zip.Reduced" ${PV} '$(libdir)'/mono/${PN}/Ionic.Zip.Reduced.dll
	if use debug; then
		insinto "${INSTALL_DIR}"
		doins "$(bin_dir)/Ionic.Zip.Reduced.pdb"
	fi

	if use source; then
		for f in $(sources1); do
			# https://stackoverflow.com/questions/10986794/remove-part-of-path-on-unix
			local FULL_DIR_NAME=$(dirname $f)
			local RELPATH=${FULL_DIR_NAME#${S}/}
			einfo "SRC: " ${RELPATH} '/' $(basename $f)
			insinto "${SRC_INSTALL_DIR}/${RELPATH}"
			doins $f
		done
	fi
}
