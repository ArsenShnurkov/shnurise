# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: dotnet.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: common settings and functions for mono and dotnet related packages
# @DESCRIPTION:
# The dotnet eclass contains common environment settings that are useful for
# dotnet packages.  Currently, it 
# exports MONO_SHARED_DIR and
# sets LC_ALL in order to prevent errors during compilation of dotnet packages.

case ${EAPI:-0} in
	0|1|2|3|4|5|6) die "this eclass doesn't support EAPI-${EAPI:-0}" ;;
	*) ;; #if [[ ${USE_DOTNET} ]]; then REQUIRED_USE="|| (${USE_DOTNET})"; fi;;
esac

# inherit mono-env - no need to include here, it's included in dotnet-native
inherit dotnet-native

# >=mono-0.92 versions using mcs -pkg:foo-sharp require shared memory, so we set the
# shared dir to ${T} so that ${T}/.wapi can be used during the install process.
export MONO_SHARED_DIR="${T}"

# Building mono, nant and many other dotnet packages is known to fail if LC_ALL
# variable is not set to C. To prevent this all mono related packages will be
# build with LC_ALL=C (see bugs #146424, #149817)
export LC_ALL=C

# Monodevelop-using applications need this to be set or they will try to create config
# files in the user's ~ dir.

export XDG_CONFIG_HOME="${T}"

SANDBOX_WRITE="${SANDBOX_WRITE}:/etc/mono/registry/:/etc/mono/registry/last-btime"

# Fix bug 83020:
# "Access Violations Arise When Emerging Mono-Related Packages with MONO_AOT_CACHE"

unset MONO_AOT_CACHE

# @ECLASS-VARIABLE: USE_DOTNET
# @DESCRIPTION: This variable enumerate all dotnet which are supported by ebuild

# SET default use flags according on DOTNET_TARGETS
for x in ${USE_DOTNET}; do
	case ${x} in
		net45) if [[ ${DOTNET_TARGETS} == *net45* ]]; then IUSE+=" +net45"; else IUSE+=" net45"; fi;;
		net40) if [[ ${DOTNET_TARGETS} == *net40* ]]; then IUSE+=" +net40"; else IUSE+=" net40"; fi;;
		net35) if [[ ${DOTNET_TARGETS} == *net35* ]]; then IUSE+=" +net35"; else IUSE+=" net35"; fi;;
		net20) if [[ ${DOTNET_TARGETS} == *net20* ]]; then IUSE+=" +net20"; else IUSE+=" net20"; fi;;
	esac
done

# @FUNCTION: dotnet_pkg_setup
# @DESCRIPTION: This function set FRAMEWORK environment variable
dotnet_pkg_setup() {
	EBUILD_FRAMEWORK=""
	mono-env_pkg_setup
	for x in ${USE_DOTNET} ; do
		case ${x} in
			net45) EBF="4.5"; if use net45; then F="${EBF}";fi;;
			net40) EBF="4.0"; if use net40; then F="${EBF}";fi;;
			net35) EBF="3.5"; if use net35; then F="${EBF}";fi;;
			net20) EBF="2.0"; if use net20; then F="${EBF}";fi;;
		esac
		if [[ -z ${FRAMEWORK} ]]; then
			if [[ ${F} ]]; then
				FRAMEWORK="${F}";
			fi
		else
			if [[ ${F} ]]; then
				ver_test "${F}" -gt "${FRAMEWORK}" || FRAMEWORK="${F}"
			fi
		fi
		if [[ -z ${EBUILD_FRAMEWORK} ]]; then
			if [[ ${EBF} ]]; then
				EBUILD_FRAMEWORK="${EBF}";
			fi
		else
			ver_test "${EBF}" -gt "${EBUILD_FRAMEWORK}" || EBUILD_FRAMEWORK="${EBF}"
		fi
	done
	if [[ -z ${FRAMEWORK} ]]; then
		if [[ -z ${EBUILD_FRAMEWORK} ]]; then
			FRAMEWORK="4.5"
			elog "Ebuild doesn't contain USE_DOTNET="
		else
			FRAMEWORK="${EBUILD_FRAMEWORK}"
			elog "User did not set any netNN use-flags in make.conf or profile, .ebuild demands USE_DOTNET=""${USE_DOTNET}"""
		fi
	fi
	einfo " -- USING .NET ${FRAMEWORK} FRAMEWORK -- "
}

# @FUNCTION: dotnet_expand
# @DESCRIPTION: expands values from the DOTNET_TARGETS variable
dotnet_expand() {
	# do nothing for now
	echo "$@"
}

function directory_modificator_for_slot()
{
	local MODIFICATOR=""
	if [ "${1}" != "0" ]; then
		MODIFICATOR="-${1}"
	fi
	echo "${MODIFICATOR}"
}

APPENDIX=$(directory_modificator_for_slot ${SLOT})
#if [ "${SLOT}" != "0" ]; then
#	APPENDIX="-${SLOT}"
#fi

# ================== Various locations ==============================

# @FUNCTION: framework_api_dir
# @DESCRIPTION: returns path to mono-api assemblies
function framework_api_dir() {
	echo "/usr/$(get_libdir)/mono/${FRAMEWORK}-api"
}

# @FUNCTION: framework_assembly_dir
# @DESCRIPTION: returns path for .dll assemblies installation
function framework_assembly_dir() {
	echo "/usr/$(get_libdir)/mono/${FRAMEWORK}/${PN}${APPENDIX}"
}

# @FUNCTION: library_assembly_dir
# @DESCRIPTION:  returns default directory for installing libraries
# @OBSOLETE: use platform_assembly_dir/platform_symlink_dir and anycpy_assembly_dir/anycpy_symlink_dir
function library_assembly_dir() {
	# note that 'dev-dotnet' is hardcoded, don't change it to '${CATEGORY}'
	# because when you referer this function from another ebuild, the category can be different
	# note that 'share' is hardcoded, don't change it to '$(get_libdir)'
	# because mono assemblies should be architecture independent in common case
	# why there is no "mono/${FRAMEWORK}" after "share" ?
	echo "/usr/share/dev-dotnet/${PN}${APPENDIX}"
}

# @FUNCTION: executable_assembly_dir
# @DESCRIPTION:  returns default directory for installing executables
# @OBSOLETE: use platform_assembly_dir and anycpy_assembly_dir
function executable_assembly_dir() {
	echo "/usr/share/${PN}${APPENDIX}"
}

# @FUNCTION: platform_assembly_dir
# @DESCRIPTION:  returns default directory for installing platform-dependent CLR assemblies
function platform_assembly_dir() {
	echo "/var/$(get_libdir)/mono/assemblies/${1}$(directory_modificator_for_slot $2)"
}

# @FUNCTION: platform_symlink_dir
# @DESCRIPTION:  returns default directory for symlinks to platform-dependent CLR assembly and it's dependencies
function platform_symlink_dir() {
	echo "/var/$(get_libdir)/mono/assemblies/${1}$(directory_modificator_for_slot $2)/bin"
}

# @FUNCTION: anycpu_assembly_dir
# @DESCRIPTION:  returns default directory for installing platform-independent CLR assemblies
function anycpu_assembly_dir() {
	echo "/usr/share/mono/assemblies/${1}$(directory_modificator_for_slot $2)"
}

# @FUNCTION: anycpu_symlink_dir
# @DESCRIPTION:  returns default directory for symlinks to platform-independent CLR assembly and it's dependencies
function anycpu_symlink_dir() {
	echo "/usr/share/mono/assemblies/${1}$(directory_modificator_for_slot $2)/bin"
}

# ========================================================================

# @FUNCTION: platform_current_assembly_dir
# @DESCRIPTION:  returns default directory for installing platform-dependent CLR assemblies
function platform_current_assembly_dir() {
	echo "$(platform_assembly_dir ${PN} ${SLOT})"
}

# @FUNCTION: platform_current_symlink_dir
# @DESCRIPTION:  returns default directory for symlinks to platform-dependent CLR assembly and it's dependencies
function platform_current_symlink_dir() {
	echo "$(platform_symlink_dir ${PN} ${SLOT})"
}

# @FUNCTION: anycpu_current_assembly_dir
# @DESCRIPTION:  returns default directory for installing platform-independent CLR assemblies
function anycpu_current_assembly_dir() {
	echo "$(anycpu_assembly_dir ${PN} ${SLOT})"
}

# @FUNCTION: anycpu_current_symlink_dir
# @DESCRIPTION:  returns default directory for symlinks to platform-independent CLR assembly and it's dependencies
function anycpu_current_symlink_dir() {
	echo "$(anycpu_symlink_dir ${PN} ${SLOT})"
}

# ========================================================================

function reference_framework() {
	echo -n " " /reference:${1}.dll
}

function reference_project() {
	echo -n " " /reference:$(bin_dir)/$1.dll
}

function reference_dependency() {
	local REF=$(pkg-config --libs ${1}) || die
	echo -n " " ${REF}
}

# @FUNCTION: csharp_sources
# @DESCRIPTION: recursively returns all .cs files from directory in $1
function csharp_sources() {
	local DIR_NAME=$1
	for f in "${DIR_NAME}"/*; do
		if [ -d "$f" ];
		then
			csharp_sources "$f"
		else
			case "$f" in
			*.cs ) 
			        # it's source code file
				echo -n ' ' $f
			        ;;
			*)
			        # it's not
			        ;;
			esac
		fi
	done
}


# @FUNCTION: usedebug_tostring
# @DESCRIPTION:  returns strings "Debug" or "Release" depending from USE="debug"
function usedebug_tostring ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${DIR}"
}

# @FUNCTION: output_relpath
# @DESCRIPTION:  returns default relative directory for Debug or Release configuration depending from USE="debug"
function output_relpath ( ) {
	echo "bin/$(usedebug_tostring)"
}

function bin_dir ( ) {
	echo "${WORKDIR}/$(output_relpath)"
}

# https://stackoverflow.com/questions/233081/whats-the-obj-directory-for-in-net
#function obj_dir ( ) {
#	echo "${WORKDIR}/obj/$(usedebug_tostring)"
#}

# https://docs.microsoft.com/ru-ru/dotnet/csharp/language-reference/compiler-options/target-library-compiler-option
function output_dll() {
	local OUTPUT_TYPE="library" 
	local OUTPUT_NAME="$(bin_dir)/$1.dll"
	echo "/target:${OUTPUT_TYPE}" "/out:${OUTPUT_NAME}"
}

# https://docs.microsoft.com/ru-ru/dotnet/csharp/language-reference/compiler-options/target-exe-compiler-option
function output_exe() {
	local OUTPUT_TYPE="exe" 
	local OUTPUT_NAME="$(bin_dir)/$1.exe"
	echo "/target:${OUTPUT_TYPE}" "/out:${OUTPUT_NAME}"
}

# @FUNCTION: eresgen
# @DESCRIPTION: wraps call to Resource converter, hides it's location and contains die call if failed
function eresgen() {
	einfo /usr/bin/resgen $@
	/usr/bin/resgen $@ >/dev/null || die "Resource conversion failed"
}

# @FUNCTION: eres2cs
# @DESCRIPTION: wraps call to .cs code generator, hides it's location and contains die call if failed
function eres2cs() {
	einfo /usr/bin/res2cs $@
	/usr/bin/res2cs $@ >/dev/null || die "Constants generation failed"
}

# @FUNCTION: ecsc
# @DESCRIPTION: wraps call to C# compiler, hides it's location and contains die call if failed
function ecsc() {
	einfo /usr/bin/csc $@
	/usr/bin/csc $@ || die "Compilation failed"
}

# @FUNCTION: elib
# @DESCRIPTION: installs .dll file into filesystem
elib () {
	elib2 $(anycpu_current_assembly_dir) $@
}

# @FUNCTION: elib2
# @DESCRIPTION: installs .dll file into filesystem into specified location
# $1 = path to install directory
# $2 = myassembly1 # path and filename with extension of the first .dll
# $3 = myassembly2 # path and filename with extension of the second .dll
# $N = myassemblyN-1 # other names
elib2 () {
	local INSTALL_PATH="$1" # 
	shift 1
	einfo "installing into ${INSTALL_PATH}"
	insinto "${INSTALL_PATH}"
	# https://unix.stackexchange.com/questions/128204/what-does-while-test-gt-0-do/128207
	while ${1+:} false ; do
		# https://stackoverflow.com/questions/2664740/extract-file-basename-without-path-and-extension-in-bash
		local ASSEMBLY_FILENAMEWEXT="${1##*/}"
		local ASSEMBLY_FILENAME="${ASSEMBLY_FILENAMEWEXT%.*}"
		einfo "ASSEMBLY_FILENAME=${ASSEMBLY_FILENAME}, ASSEMBLY_FILENAMEWEXT=${ASSEMBLY_FILENAMEWEXT}"
		einfo "doins \"$1\""
		doins "$1"
		einfo "elib: $1 is installed as ${INSTALL_PATH}/${ASSEMBLY_FILENAMEWEXT}"

#		einstall_pc_file "${ASSEMBLY_FILENAME}" "${PV}" "${INSTALL_PATH}/${ASSEMBLY_FILENAMEWEXT}"
#		^^^ this should be moved into "doins.dll" function in msbuild.eclass

		shift
	done
	einfo "elib finished"
}

EXPORT_FUNCTIONS pkg_setup

