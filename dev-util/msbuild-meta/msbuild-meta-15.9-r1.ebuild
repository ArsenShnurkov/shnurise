# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
KEYWORDS="amd64 arm64"

SLOT="0"

# it's impossible to use
# inherit msbuild-framework
# ?DEPEND=" ... dev-dotnet/gentoo-net-sdk[$(msbuild_expand msbuild15-9)]"
# will say
# (masked by: invalid: DEPEND: Invalid atom (dev-dotnet/gentoo-net-sdk[), token 3,
# invalid: RDEPEND: Invalid atom (dev-dotnet/gentoo-net-sdk[), token 3)
#
# that's why the full name is used for USE-flag "msbuild_targets_msbuild15-9"
#     dev-dotnet/gentoo-net-sdk[msbuild_targets_msbuild15-9]

CDEPEND="
	>=dev-util/msbuild-15.9
	app-eselect/eselect-msbuild
	dev-dotnet/gentoo-net-sdk[msbuild_targets_msbuild15-9]
"

RDEPEND="${CDEPEND}
"

DEPEND="${CDEPEND}
"
#	>=dev-dotnet/msbuildtasks-1.5.0.240-r1
