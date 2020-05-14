# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: msbuild-framework.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: Bits for writing Sdks for msbuild framework API
# @DESCRIPTION: contain paths in the VFS

case ${EAPI:-0} in
	0|1|2|3|4|5|6) die "this eclass doesn't support EAPI 0..6" ;;
	*) ;; #if [[ ${USE_MSBUILD} ]]; then REQUIRED_USE="|| (${USE_MSBUILD})"; fi;;
esac

#inherit versionator

DEPEND+=" dev-dotnet/msbuild-tasks-api"

# @FUNCTION: msbuild_expand
# @DESCRIPTION: expands values from the MSBUILD_TARGETS variable
msbuild_expand() {
	local res=""
	for word in $@; do
		res="${res} ${word//msbuild/msbuild_targets_msbuild}"
	done
	echo "${res}"
}

# @FUNCTION: MSBuildExtensionsPath
# @DESCRIPTION: root directory for different version of tools
MSBuildExtensionsPath () {
	echo "/usr/share/msbuild"
}

# @FUNCTION: MSBuildToolsVersion
# @DESCRIPTION: version of tools
# for use only from slotted ebuilds
BuildToolsVersion () {
	# https://dev.gentoo.org/~mgorny/articles/the-ultimate-guide-to-eapi-7.html#replacing-versionator-eclass-uses
	# get_version_component_range -> ver_cut
	#
	# https://devmanual.gentoo.org/eclass-reference/eapi7-ver.eclass/index.html
	# ver_cut <range> [<version>]
	#    Print the substring of the version string containing components defined by the <range> and the version separators between them. Processes <version> if specified, ${PV} otherwise.
	#
	# A range can be specified as 'm' for m-th version component, 'm-' for all components starting with m-th or 'm-n' for components starting at m-th and ending at n-th (inclusive).
	# If the range spans outside the version string, it is truncated silently. 
	echo "$(ver_cut 1-2 ${SLOT}).0"
}

# @FUNCTION: MSBuildToolsPath
# @DESCRIPTION: location of .target files
# https://docs.microsoft.com/en-US/visualstudio/msbuild/msbuild-dot-targets-files?view=vs-2019
MSBuildToolsPath () {
	# https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
	if [ -z ${TargetVersion+x} ]; then
		TargetVersion = "${SLOT}"
	fi
	echo "$(MSBuildExtensionsPath)/${TargetVersion}"
}

# @FUNCTION: MSBuildBinPath
# @DESCRIPTION: location of msbuild.exe
# for use only from slotted ebuilds
MSBuildBinPath () {
	echo "$(MSBuildToolsPath)/bin"
}

# @FUNCTION: MSBuildSdksPath
# @DESCRIPTION: location of Sdks directory
# for use only from slotted ebuilds
MSBuildSdksPath () {
	echo "$(MSBuildBinPath)/Sdks"
}
