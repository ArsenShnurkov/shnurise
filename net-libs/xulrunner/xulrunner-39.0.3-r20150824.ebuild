# Copyright 1999-2015 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

DESCRIPTION="Mozilla runtime package that can be used to bootstrap XUL+XPCOM applications"
LICENSE="|| ( MPL-1.1 GPL-2 LGPL-2.1 )"
HOMEPAGE="https://developer.mozilla.org/en-US/docs/Mozilla/Projects/XULRunner"

inherit eutils autotools
WANT_AUTOCONF="2.1"

EGIT_COMMIT="ae994d2e5b6f5705b4d367f8cc3ad0c2367d3bcb"
SRC_URI="https://github.com/mozilla/gecko-dev/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"


KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
SLOT="0"
IUSE="+alsa +cups debug +ipc libnotify system-sqlite +webm wifi"




RDEPEND="
	>=sys-devel/binutils-2.16.1
	>=dev-libs/nss-3.12.8_beta1
	>=dev-libs/nspr-4.8.5
	>=app-text/hunspell-1.2
	>=x11-libs/cairo-1.8.8[X]
	>=dev-libs/libevent-1.4.7
	x11-libs/pango[X]
	x11-libs/libXt
	x11-libs/pixman
	alsa? ( media-libs/alsa-lib )
	libnotify? ( >=x11-libs/libnotify-0.4 )
	system-sqlite? ( >=dev-db/sqlite-3.7.0.1[fts3,secure-delete,unlock-notify] )
	wifi? ( net-wireless/wireless-tools )
	cups? ( net-print/cups[gnutls] )
	!www-plugins/weave"

DEPEND="${RDEPEND}
	=dev-lang/python-2*[threads]
	dev-util/pkgconfig"

pkg_setup() {
	# Ensure we always build with C locale.
	export LANG="C"
	export LC_ALL="C"
	export LC_MESSAGES="C"
	export LC_CTYPE="C"

	python_set_active_version 2
}

src_prepare() {
    :;
}

src_configure() {
    :;
}

src_install() {
    :;
}
