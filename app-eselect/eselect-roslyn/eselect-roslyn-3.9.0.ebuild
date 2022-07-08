# Copyright 1999-2028 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="amd64 ~arm64"
RESTRICT+="mirror"
RESTRICT+="test"

SLOT="0"
LICENSE="GPL-2"

DESCRIPTION="roslyn eselect module"
HOMEPAGE="https://github.com/ArsenShnurkov/shnurise"

inherit vcs-snapshot

GITHUB_ACCOUNT="ArsenShnurkov"
GITHUB_PROJECTNAME="eselect-msbuild"
EGIT_COMMIT="8e36a710a1fc4f9839d952dc3ebcfd973661437a"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz
	"
S="${WORKDIR}/${CATEGORY}-${PN}-${PV}"

RDEPEND="app-admin/eselect"

IUSE=""

src_install() {
	insinto /usr/share/eselect/modules
	newins "${S}/roslyn.eselect" roslyn.eselect || die
}
