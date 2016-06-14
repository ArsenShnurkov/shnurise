# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit eutils dotnet

DESCRIPTION="mypad text editor"
LICENSE="MIT"

PROJECTNAME="mypad-winforms-texteditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="2e188318be0827f732ee71831646d7e1a4b63876"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"

SLOT="1"
IUSE="net45 debug developer"
USE_DOTNET="net45"

KEYWORDS="amd64 ppc x86"

ALLPEND="|| ( >=dev-lang/mono-4 <dev-lang/mono-9999 )
	|| ( dev-dotnet/icsharpcodetexteditor[nupkg] dev-dotnet/icsharpcodetexteditor[gac] )
	"

# The DEPEND ebuild variable should specify any dependencies which are 
# required to unpack, patch, compile or install the package
DEPEND="${ALLPEND}
	dev-dotnet/nuget
	"

# The RDEPEND ebuild variable should specify any dependencies which are 
# required at runtime. 
# when installing from a binary package, only RDEPEND will be checked.
RDEPEND="${ALLPEND}
	"

S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

# METAFILETOBUILD=${PROJECTNAME}.sln
METAFILETOBUILD=MyPad.sln

pkg_preinst() {
	gnome2_icon_savelist
}

src_prepare() {
#	elog "Patching"
	eapply "${FILESDIR}/0001-remove-project-from-solution.patch"
	eapply "${FILESDIR}/0001-.csproj-dependency-.nupkg-dependency.patch"
	elog "NuGet restore"
	/usr/bin/nuget restore ${METAFILETOBUILD} || die
	eapply_user
}

src_compile() {
	# https://bugzilla.xamarin.com/show_bug.cgi?id=9340
	exbuild ${METAFILETOBUILD}
}

src_install() {
	local ICON_NAME=AtomFeedIcon.svg
	local FULL_ICON_NAME=MyPad/Resources/${AtomFeedIcon.svg}
	elog "Installing executable"
	insinto /usr/lib/mypad-${PV}/
	make_wrapper mypad "mono /usr/lib/mypad-${PV}/mypad.exe"
	newicon -s scalable "${FULL_ICON_NAME}" "${ICON_NAME}"
	make_desktop_entry "/usr/lib/mypad-${PV}/mypad.exe" "${DESCRIPTION}" "/usr/share/icons/hicolor/scalable/apps/${ICON_NAME}"
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
