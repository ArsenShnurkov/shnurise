# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="amd64 arm64"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +symlink"

inherit multilib eutils vcs-snapshot
inherit dotnet

HOMEPAGE="https://github.com/mono/roslyn-binaries"

GITHUB_REPONAME="roslyn-binaries"
GITHUB_ACCOUNT="mono"
EGIT_COMMIT="1c6482470cd219dcc7503259a20f26a1723f20ec"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"
#S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

DESCRIPTION="Roslyn binary files compiled by Microsoft and repackaged by mono team"
LICENSE="MIT" # https://github.com/dotnet/roslyn/blob/main/License.txt

RDEPEND="
    app-admin/eselect
    app-admin/eselect-roslyn
    "

src_prepare() {
	eapply_user
}


src_install() {
	local INSTALL_PATH="/usr/x86_64-msbin-roslyn/"
	insinto ${INSTALL_PATH}
	doins Microsoft.Net.Compilers/${PV}/*

	if use symlink; then
		eselect roslyn "${PN}-${PV}" || die
	fi
}
