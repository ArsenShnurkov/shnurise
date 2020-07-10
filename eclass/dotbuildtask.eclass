# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: dotbuildtask.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for installing msbuild task assembly
# @DESCRIPTION:
# It is separated into it's own file to provide ability to define default src_install function for msbuild tasks ebuilds

case ${EAPI:-0} in
	0) die "this eclass doesn't support EAPI 0" ;;
	1|2|3) ;;
	*) ;; #if [[ ${USE_DOTNET} ]]; then REQUIRED_USE="|| (${USE_DOTNET})"; fi;;
esac

inherit multilib msbuild

# @FUNCTION: get_MSBuildExtensionsPath
# @DESCRIPTION: returns path to .targets files
get_MSBuildExtensionsPath() {
	echo /usr/share/msbuild
}

# @FUNCTION: einstask
# @DESCRIPTION: installs Tasks.dll into default location
# first argument is .dll name which is installed into $(get_dotlibdir)
# get_dotlibdir is not defined anywhere!!!
# all other arguments are files which are installed into $(get_MSBuildExtensionsPath)
einstask() {
	if [[ $# -lt 1 ]]; then
		die "Illegal number of parameters"
	fi
	elog installing msbuild task dll "$1" into "$(get_MSBuildExtensionsPath)"
	insinto "$(get_MSBuildExtensionsPath)"
	doins $1

	shift

	for var in "$@"
	do
			elog installing file task dll "${var}" into "$(get_MSBuildExtensionsPath)"
			insinto "$(get_MSBuildExtensionsPath)"
			doins ${var}
	done
}

get_MSBuildSdksPath() {
	echo "$(get_MSBuildExtensionsPath)/Sdks"
}

# @FUNCTION: einssdk
# @DESCRIPTION: installs *.props and *.targets into default location for Sdk
# first argument is Sdk name
# all other arguments are files which are installed into $(get_MSBuildSdksPath)
einssdk() {
	if [[ $# -lt 1 ]]; then
		die "Illegal number of parameters"
	fi
	local SDK_NAME=$1

	shift

	local INSTALL_PATH="$(get_MSBuildSdksPath)/${SDK_NAME}/Sdk"
	insinto "${INSTALL_PATH}"
	for var in "$@"
	do
			elog installing file "${var}" into "${INSTALL_PATH}"
			doins ${var}
	done
}
