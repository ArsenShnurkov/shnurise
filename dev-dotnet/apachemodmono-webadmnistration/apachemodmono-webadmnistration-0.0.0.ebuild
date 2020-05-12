# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="amd64"
RESTRICT="mirror"

SLOT="0" # if ommitted gives the message: "SLOT: invalid value: ''" during "ebuild digest" operation

USE_DOTNET="net45"

IUSE="+${USE_DOTNET} pkg-config debug developer"

inherit dotnet mono-pkg-config

DESCRIPTION="API for managing Apache and mod-mono-server4"

PROJECTNAME="ApacheModmono.Web.Administration"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
LICENSE="Apache-2.0"
EGIT_COMMIT="82862af30f3a0134e38454fbd44c09b62f50a38c"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${CATEGORY}-${PN}-${PV}.zip"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

DEPEND=""
RDEPEND="${DEPEND}	"

if [ "${SLOT}" != "0" ]; then
	APPENDIX="-${SLOT}"
fi

function install_dir() {
#	echo "/usr/lib/ApacheModmono.Web.Administration${APPENDIX}"
	echo "$(anycpu_current_assembly_dir)"
}

function references() {
	echo -n " " /reference:System.dll
}

function obj_dir ( ) {
	echo "${WORKDIR}/obj/$(usedebug_tostring)"
}

function bin_dir ( ) {
	echo "${WORKDIR}/bin/$(usedebug_tostring)"
}

function output_arguments ( ) {
	local OUTPUT_TYPE="library" # https://docs.microsoft.com/ru-ru/dotnet/csharp/language-reference/compiler-options/target-exe-compiler-option
	local OUTPUT_NAME="$(bin_dir)/ApacheModmono.Web.Administration.dll"
	echo  "/target:${OUTPUT_TYPE}" "/out:${OUTPUT_NAME}"
}

src_compile() {
	mkdir -p $(bin_dir) || die
	/usr/bin/csc $(references) $(csharp_sources "${S}/ApacheModmono.Web.Administration") $(output_arguments) || die
}

src_install() {
	insinto "$(install_dir)"
	doins "$(bin_dir)/ApacheModmono.Web.Administration.dll"
	einstall_pc_file "ApacheModmono.Web.Administration" "${PV}" $(install_dir)/ApacheModmono.Web.Administration.dll
}
