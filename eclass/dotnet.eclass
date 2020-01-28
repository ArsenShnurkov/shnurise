# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: dotnet.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: common settings and functions for mono and dotnet related packages
# @DESCRIPTION:
# The dotnet eclass contains common environment settings that are useful for
# dotnet packages.  Currently, it 
# exports MONO_SHARED_DIR ans
# sets LC_ALL in order to prevent errors during compilation of dotnet packages.

case ${EAPI:-0} in
	0) die "this eclass doesn't support EAPI 0" ;;
	1|2|3) ;;
	*) ;; #if [[ ${USE_DOTNET} ]]; then REQUIRED_USE="|| (${USE_DOTNET})"; fi;;
esac

inherit eutils
#inherit versionator
#inherit eapi7-ver
inherit mono-env

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

if [ "${SLOT}" != "0" ]; then
	APPENDIX="-${SLOT}"
fi

# SRC_URI+=" https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
# I was unable to append SRC_URI variable this ^^ way

# @FUNCTION: csharp_sources
# @DESCRIPTION: recursively returns all .cs files from directory in $1
function csharp_sources() {
	local DIR_NAME=$1
	for f in "${DIR_NAME}"/*; do
		if [ -d $f ];
		then
			csharp_sources "$f"
		else
			case "$f" in
			*.cs ) 
			        # it's source code file
				echo -n "$f "
			        ;;
			*)
			        # it's not
			        ;;
			esac
		fi
	done
}

# @FUNCTION: dotnet_expand
# @DESCRIPTION: expands values from the DOTNET_TARGETS variable
dotnet_expand() {
	# do nothing for now
	echo "$@"
}

# @FUNCTION: dotnet_pkg_setup
# @DESCRIPTION:  This function set FRAMEWORK variable
dotnet_pkg_setup() {
	EBUILD_FRAMEWORK=""
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
			version_is_at_least "${F}" "${FRAMEWORK}" || FRAMEWORK="${F}"
		fi
		if [[ -z ${EBUILD_FRAMEWORK} ]]; then
			if [[ ${EBF} ]]; then
				EBUILD_FRAMEWORK="${EBF}";
			fi
		else
			version_is_at_least "${EBF}" "${EBUILD_FRAMEWORK}" || EBUILD_FRAMEWORK="${EBF}"
		fi
	done
	if [[ -z ${FRAMEWORK} ]]; then
		if [[ -z ${EBUILD_FRAMEWORK} ]]; then
			FRAMEWORK="4.0"
			elog "Ebuild doesn't contain USE_DOTNET="
		else
			FRAMEWORK="${EBUILD_FRAMEWORK}"
			elog "User did not set any netNN use-flags in make.conf or profile, .ebuild demands USE_DOTNET=""${USE_DOTNET}"""
		fi
	fi
	einfo " -- USING .NET ${FRAMEWORK} FRAMEWORK -- "
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

# ========================================================================

function directory_modificator_for_slot()
{
	local MODIFICATOR=""
	if [ "${1}" != "0" ]; then
		MODIFICATOR="-${1}"
	fi
	echo "${MODIFICATOR}"
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

# @FUNCTION: dotnet_multilib_comply
# @DESCRIPTION:  multilib comply
dotnet_multilib_comply() {
	use !prefix && has "${EAPI:-0}" 0 1 2 && ED="${D}"
	local dir finddirs=() mv_command=${mv_command:-mv}
	if [[ -d "${ED}/usr/lib" && "$(get_libdir)" != "lib" ]]
	then
		if ! [[ -d "${ED}"/usr/"$(get_libdir)" ]]
		then
			mkdir "${ED}"/usr/"$(get_libdir)" || die "Couldn't mkdir ${ED}/usr/$(get_libdir)"
		fi
		${mv_command} "${ED}"/usr/lib/* "${ED}"/usr/"$(get_libdir)"/ || die "Moving files into correct libdir failed"
		rm -rf "${ED}"/usr/lib
		for dir in "${ED}"/usr/"$(get_libdir)"/pkgconfig "${ED}"/usr/share/pkgconfig
		do

			if [[ -d "${dir}" && "$(find "${dir}" -name '*.pc')" != "" ]]
			then
				pushd "${dir}" &> /dev/null
				sed  -i -r -e 's:/(lib)([^a-zA-Z0-9]|$):/'"$(get_libdir)"'\2:g' \
					*.pc \
					|| die "Sedding some sense into pkgconfig files failed."
				popd "${dir}" &> /dev/null
			fi
		done
		if [[ -d "${ED}/usr/bin" ]]
		then
			for exe in "${ED}/usr/bin"/*
			do
				if [[ "$(file "${exe}")" == *"shell script text"* ]]
				then
					sed -r -i -e ":/lib(/|$): s:/lib(/|$):/$(get_libdir)\1:" \
						"${exe}" || die "Sedding some sense into ${exe} failed"
				fi
			done
		fi

	fi
}

EXPORT_FUNCTIONS pkg_setup

