# Copyright 1999-2013 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/app-office/openproj-bin/openproj-bin-1.4-r1.ebuild,v 1.3 2013/08/07 13:22:59 ago Exp $

EAPI=5

inherit eutils

MY_PN=${PN/-bin}
MY_P="${MY_PN}-${PV}"
DESCRIPTION="A free and open source desktop alternative to Microsoft Project"
HOMEPAGE="http://www.projectlibre.org/"
SRC_URI="mirror://sourceforge/${MY_PN}/ProjectLibre/${PV}/${MY_P}.tar.gz
	http://sourceforge.net/p/projectlibre/code/ci/master/tree/openproj_build/resources/${MY_PN}.desktop?format=raw -> ${MY_PN}.desktop
	http://sourceforge.net/p/projectlibre/code/ci/master/tree/openproj_build/resources/${MY_PN}.png?format=raw -> ${MY_PN}.png"

LICENSE="CPAL-1.0"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="virtual/jre"
DEPEND=""

S=${WORKDIR}/${MY_P}

src_unpack() {
	unpack ${MY_P}.tar.gz
	cp "${DISTDIR}"/${MY_PN}.{desktop,png} ./ || die
	cd "${S}"
	rm -rf license ${MY_PN}.bat readme.html
}

src_prepare() {
	sed -i \
		-e "/^OPENPROJ_HOME0=/s:=.*:=/opt/${MY_PN}:" \
		${MY_PN}.sh || die
}

src_install() {
	local d="/opt/${MY_PN}"
	insinto ${d}
	doins -r * || die
	fperms a+rx ${d}/${MY_PN}.sh

	dodir /opt/bin
	dosym ../${MY_PN}/${MY_PN}.sh /opt/bin/${MY_PN} || die

	doicon ../${MY_PN}.png
	domenu ../${MY_PN}.desktop
	#newicon ../${MY_P}.png ${MY_PN}.png || die
	#newmenu ../${MY_P}.desktop ${MY_PN}.desktop || die
}
