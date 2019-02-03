# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: msbuild-framework.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: Bits for writing Sdks for msbuild framework API
# @DESCRIPTION: contain paths in the VFS

case ${EAPI:-0} in
	0) die "this eclass doesn't support EAPI 0" ;;
	1|2|3) ;;
	*) ;; #if [[ ${USE_MSBUILD} ]]; then REQUIRED_USE="|| (${USE_MSBUILD})"; fi;;
esac

DEPEND+=" dev-util/msbuild-tasks-api"

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

# @FUNCTION: MSBuildBinPath
# @DESCRIPTION: location of msbuild.exe
# for use only from slotted ebuilds
MSBuildBinPath () {
	# https://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash
	if [-z ${MSBuildToolsVersion+x} ]; then
		MSBuildToolsVersion = "${SLOT}"
	fi
	echo "$(MSBuildExtensionsPath)/${MSBuildToolsVersion}"
}

# @FUNCTION: MSBuildSdksPath
# @DESCRIPTION: location of Sdks directory
# for use only from slotted ebuilds
MSBuildSdksPath () {
	echo "$(MSBuildBinPath)/Sdks"
}

