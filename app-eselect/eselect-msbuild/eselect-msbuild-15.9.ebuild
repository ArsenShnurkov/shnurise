# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="0"
LICENSE="GPL-2"

DESCRIPTION="msbuild eselect module"
HOMEPAGE="https://github.com/ArsenShnurkov/shnurise"

GITHUB_ACCOUNT="ArsenShnurkov"
GITHUB_PROJECTNAME="eselect-msbuild"
EGIT_COMMIT="7da8a8f3a5114e4583efe5206b545bc701145b73"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz
	"

S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

RDEPEND="app-admin/eselect"

IUSE=""

src_install() {
	insinto /usr/share/eselect/modules
	newins "${S}/msbuild.eselect" msbuild.eselect || die
}
