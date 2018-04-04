# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer doc"

inherit dotnet

GITHUB_ACCOUNT="mono"
GITHUB_PROJECTNAME="t4"
EGIT_COMMIT="0a1424821b493704b4e8ecaee8f6378b8893c0c8"
HOMEPAGE="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

COMMON_DEPEND="
	>=dev-dotnet/mono-options-5.11.0.132
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply_user
}

src_compile() {
	:;
}

src_install() {
	:;
}
