# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit fdo-mime gnome2-utils dotnet versionator eutils

DESCRIPTION="Integrated Development Environment for .NET"
HOMEPAGE="http://www.monodevelop.com/"
SRC_URI="https://github.com/mono/monodevelop/archive/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="562"
KEYWORDS="~amd64 ~x86"
IUSE="+subversion +git doc"

RDEPEND=">=dev-lang/mono-3.2.8
	>=dev-dotnet/gnome-sharp-2.24.0
	>=dev-dotnet/gtk-sharp-2.12.9
	>=dev-dotnet/mono-addins-0.6[gtk]
	>=dev-dotnet/xsp-2
	dev-util/ctags
	doc? ( dev-util/mono-docbrowser )
	subversion? ( dev-vcs/subversion )
	sys-apps/dbus[X]
	|| (
		www-client/firefox
		www-client/firefox-bin
		www-client/seamonkey
		)
	!<dev-util/monodevelop-boo-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-java-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-database-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-debugger-gdb-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-debugger-mdb-$(get_version_component_range 1-2)
	!<dev-util/monodevelop-vala-$(get_version_component_range 1-2)
"

DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	x11-misc/shared-mime-info
	x11-terms/xterm
"

MAKEOPTS="${MAKEOPTS} -j1" #nowarn

S="${WORKDIR}/${PN}-${P}"

src_configure() {
    ./configure	${EXTRA_ECONF} || die
    make dist
#	econf \
#		--disable-update-mimedb \
#		--disable-update-desktopdb \
#		--enable-monoextensions \
#		--enable-gnomeplatform \
#		$(use_enable subversion) \
#		$(use_enable git)
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_mime_database_update
	fdo-mime_desktop_database_update
}
