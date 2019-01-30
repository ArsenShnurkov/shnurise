# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: msbuild-locations.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: locations for installing msbuild command line utility
# @DESCRIPTION: contain paths in the VFS

case ${EAPI:-0} in
	0) die "this eclass doesn't support EAPI 0" ;;
	1|2|3) ;;
	*) ;; #if [[ ${USE_MSBUILD} ]]; then REQUIRED_USE="|| (${USE_MSBUILD})"; fi;;
esac

# @FUNCTION: MSBuildBinPath
# @DESCRIPTION: location of msbuild.exe
MSBuildBinPath () {
	echo "/usr/share/${PN}/${SLOT}"
}

# @FUNCTION: MSBuildSdksPath
# @DESCRIPTION: location of Sdks directory
MSBuildSdksPath () {
	echo "$(MSBuildBinPath)/Sdks"
}
