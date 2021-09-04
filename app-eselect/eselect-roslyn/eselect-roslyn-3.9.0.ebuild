# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
KEYWORDS="amd64 arm64"
RESTRICT="mirror"

SLOT="0"
LICENSE="GPL-2"

DESCRIPTION="msbuild eselect module"
HOMEPAGE="https://github.com/ArsenShnurkov/shnurise"

inherit vcs-snapshot

GITHUB_ACCOUNT="ArsenShnurkov"
GITHUB_PROJECTNAME="eselect-msbuild"
EGIT_COMMIT="fc3708425a1b15b3cad8b06ce75ed7853624802e"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz
	"
# S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

RDEPEND="app-admin/eselect"

IUSE=""

src_install() {
	insinto /usr/share/eselect/modules
	newins "${S}/roslyn.eselect" roslyn.eselect || die
}
