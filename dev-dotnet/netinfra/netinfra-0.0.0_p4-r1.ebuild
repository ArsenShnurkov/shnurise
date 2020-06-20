# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
KEYWORDS="amd64"
RESTRICT="mirror test"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config source debug developer"

inherit msbuild
inherit mono-pkg-config

DESCRIPTION="classes to store configuration of computers "

HOMEPAGE="https://github.com/ArsenShnurkov/netinfra"
GITHUB_REPONAME="netinfra"
LICENSE="GPL-3"

EGIT_COMMIT="1e9db1f509a46d3cefa7c9c975fdf17a79cb08df"

SRC_URI="https://codeload.github.com/ArsenShnurkov/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

METAFILETOBUILD="network/network.csproj"

function output_dir()
{
	echo "${WORKDIR}/net_${FW_UPPER}_${FW_LOWER}_$(usedebug_tostring)"
}

src_compile() {
	for x in ${USE_DOTNET} ; do
		FW_UPPER=${x:3:1}
		FW_LOWER=${x:4:1}
		P_FW_VERSION="/p:TargetFrameworkVersion=v${FW_UPPER}.${FW_LOWER}"
		emsbuild_raw ${P_FW_VERSION} /p:Configuration=$(usedebug_tostring) \
			 /p:OutputPath="$(output_dir)" "${METAFILETOBUILD}"
	done
}

src_install() {
	for x in ${USE_DOTNET} ; do
		FW_UPPER=${x:3:1}
		FW_LOWER=${x:4:1}

		local INSTALL_DIR="$(anycpu_current_assembly_dir)/dotnet-${FW_UPPER}.${FW_LOWER}"

		insinto "${INSTALL_DIR}"
		elib "${INSTALL_DIR}" $(output_dir)/network.dll

#		einstall_pc_file "${PN}" "${PV}" network
	done
}
