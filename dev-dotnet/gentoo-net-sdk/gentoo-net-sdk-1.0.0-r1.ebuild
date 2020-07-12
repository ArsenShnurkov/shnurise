# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer +symlink"

inherit dotnet
inherit dotbuildtask
inherit msbuild-framework

DEPEND="dev-dotnet/msbuild-tasks-api:15.9"

HOMEPAGE="https://github.com/ArsenShnurkov/mono-packaging-tools"
DESCRIPTION="Alternative build sequence with PkgConfig instead of NuGet"
LICENSE="GPL-3"

EGIT_COMMIT="fe4862291044ec87e2ab9dfc112e047bd68b082b"
GITHUB_PROJECTNAME="mono-packaging-tools"
GITHUB_ACCOUNT="ArsenShnurkov"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

function references() {
	echo -n \
		$(reference_dependency Microsoft.Build.Framework-15.9) \
		$(reference_framework System)
}

src_compile() {
	mkdir -p $(bin_dir) || die
	ecsc $(references) $(csharp_sources Gentoo.NET.Sdk/Gentoo.NET.Sdk.Tasks) $(output_dll Gentoo.NET.Sdk.Tasks)
}

src_install () {
	einstask "$(bin_dir)/Gentoo.NET.Sdk.Tasks.dll"
	einssdk "Gentoo.NET.Sdk" \
		"${S}/Gentoo.NET.Sdk/sdk/Sdk.props" \
		"${S}/Gentoo.NET.Sdk/sdk/Sdk.targets"
}

pkg_postinst() {
	einfo "pkg_postinst"
	if use symlink; then
		MSBUILD_TARGET="15.9"
		local LINKNAME1="${PREFIX}/$(MSBuildSdksPath)/Microsoft.NET.Sdk"
		local TARGET1="${PREFIX}/$(get_MSBuildSdksPath)/Gentoo.NET.Sdk"
		local LINKNAME="${LINKNAME1//\/\///}"
		local TARGET="${TARGET1//\/\///}"
		einfo Symlinking "${LINKNAME}" -\> "${TARGET}"
		ln -s -n --force -T  "${TARGET}" "${LINKNAME}"     || die
	fi
}
