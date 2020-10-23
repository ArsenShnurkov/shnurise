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

# @FUNCTION: target_to_slot
# @DESCRIPTION: converts string(s) like "msbuild15-9" into "15.9"
target_to_slot() {
	local res=""
	for word in $@; do
		local DEF=${MSBUILD_TARGET/msbuild/}
		if [[ ! -z "$res" ]]; then
			res="${res} "
		fi
		res="${res}${DEF/-/.}"
	done
	echo "${res}"
}

# @FUNCTION: MSBuildToolsVersion
# @DESCRIPTION: version of tools
# for use only from slotted ebuilds
MSBuildToolsVersion () {
	# https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
	if [ -z ${MSBUILD_TARGET+x} ]; then
		local VER="$(ver_cut 1-2 ${SLOT})"
		MSBUILD_TARGET="msbuild${VER/./-}"
	fi

	# https://dev.gentoo.org/~mgorny/articles/the-ultimate-guide-to-eapi-7.html#replacing-versionator-eclass-uses
	# get_version_component_range -> ver_cut
	#
	# https://devmanual.gentoo.org/eclass-reference/eapi7-ver.eclass/index.html
	# ver_cut <range> [<version>]
	#    Print the substring of the version string containing components defined by the <range> and the version separators between them. Processes <version> if specified, ${PV} otherwise.
	#
	# A range can be specified as 'm' for m-th version component, 'm-' for all components starting with m-th or 'm-n' for components starting at m-th and ending at n-th (inclusive).
	# If the range spans outside the version string, it is truncated silently.
	echo $(target_to_slot "${MSBUILD_TARGET}")
}

# @FUNCTION: MSBuildExtensionsPath
# @DESCRIPTION: root directory for different version of tools
MSBuildExtensionsPath () {
	echo "/usr/share/msbuild"
}

# @FUNCTION: MSBuildToolsPath
# @DESCRIPTION: location of .target files
# https://docs.microsoft.com/en-US/visualstudio/msbuild/msbuild-dot-targets-files?view=vs-2019
MSBuildToolsPath () {
	echo "$(MSBuildExtensionsPath)/$(MSBuildToolsVersion)"
}

# @FUNCTION: MSBuildBinPath
# @DESCRIPTION: location of msbuild.exe
# for use only from slotted ebuilds
MSBuildBinPath () {
	echo "$(MSBuildToolsPath)"
}

# @FUNCTION: MSBuildSdksPath
# @DESCRIPTION: location of Sdks directory
# ./Sdks relative position to MSBuildToolsPath is hardcoded in line 
#     defaultSdkPath = Path.Combine(CurrentMSBuildToolsDirectory, "Sdks");
# of file
# https://github.com/dotnet/msbuild/blob/master/src/Shared/BuildEnvironmentHelper.cs#L590
# it can be overriden with environment variable
# MSBuildSDKsPath=/usr/share/msbuild/15.9/Sdks msbuild some_project.sln
# but not from MSBuild.exe.config
# that is why "$(MSBuildBinPath)/Sdks" instead of "$(MSBuildToolsPath)/Sdks"
MSBuildSdksPath () {
	echo "$(MSBuildBinPath)"/Sdks
}

# @FUNCTION: RoslynTargetsPath
# @DESCRIPTION: location of .targets files for roslyn compiler
# this eclass promotes
# "$(MSBuildBinPath)/Roslyn"
# mono installs it's own copy at path
# /usr/lib/mono/msbuild/Current/bin/Roslyn
RoslynTargetsPath () {
	echo "$(MSBuildBinPath)"/Roslyn
}
