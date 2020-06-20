# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
KEYWORDS="amd64"

SLOT="0"

CDEPEND="
	>=dev-util/msbuild-15.9
	app-eselect/eselect-msbuild
	dev-dotnet/microsoft-net-sdk[msbuild_targets_msbuild15-9]
"

RDEPEND="${CDEPEND}
"

DEPEND="${CDEPEND}
"
#	>=dev-dotnet/msbuildtasks-1.5.0.240-r1
