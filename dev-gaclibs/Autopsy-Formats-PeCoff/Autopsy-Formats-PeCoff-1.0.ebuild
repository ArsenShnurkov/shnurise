# Copyright 1999-2015 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet

DESCRIPTION="Safe and static parsing for PE/COFF/LIB formats"
LICENSE="MIT"
SLOT="0"

IUSE="debug"

NAME="Autopsy.Formats.PeCoff"
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"
EGIT_COMMIT="061d8a27b13db5a76cae4757bb902b2808494a83"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}.zip"

KEYWORDS="~x86 ~amd64 ~ppc"
DEPEND="|| ( >=dev-lang/mono-3.12.0 <dev-lang/mono-9999 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

PRJ=${NAME}
FULLSLN=${NAME}.sln

src_compile() {
	exbuild ${FULLSLN}
}

src_install() {
	elog "Installing ${PRJ}.dll into GAC "
	egacinstall bin/Release/${PRJ}.dll
}
