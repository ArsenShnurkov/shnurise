# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"
RESTRICT="mirror"
SLOT="1"
USE_DOTNET="net45"
IUSE="${USE_DOTNET} debug developer"

inherit eutils gnome2-utils msbuild
# mpt-r20150903

DESCRIPTION="mypad text editor"
LICENSE="MIT"

PROJECTNAME="mypad-winforms-texteditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="a77d224023c052bd2c419bf59beb15c028d406cb"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

KEYWORDS="amd64 ppc x86"

ALLPEND="dev-lang/mono
	>=dev-dotnet/icsharpcodetexteditor-3.2.2_p2017112101
	>=dev-dotnet/ndepend-path-0.0_p20151123-r1
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

PROJECT1_PATH=MyPad
PROJECT1_NAME=MyPad
PROJECT1_OUT=MyPad

pkg_preinst() {
	gnome2_icon_savelist
}

src_prepare() {
	cp "${FILESDIR}/${PROJECT1_NAME}.csproj" "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
	sed -i "/Version/d" "${S}/MyPad/Properties/AssemblyInfo.cs" || die
#	empt-csproj --dir="${S}/${NAME}" --replace-reference "ICSharpProject.TextEditor"
	eapply_user
}

src_compile() {
	# https://bugzilla.xamarin.com/show_bug.cgi?id=9340
	emsbuild /p:TargetFrameworkVersion=v4.6 "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj"
}

src_install() {
	local BINDIR=""
	if use debug; then
		BINDIR=MyPad/bin/Debug
	else
		BINDIR=MyPad/bin/Release
	fi

	elog "Installing executable"
	insinto /usr/lib/mypad-${PV}/
	newins "${BINDIR}/MyPad.exe" MyPad.exe
	make_wrapper mypad "mono /usr/lib/mypad-${PV}/MyPad.exe"

	elog "Installing syntax coloring schemes for editor"
	dodir /usr/lib/mypad-${PV}/Modes
	insinto /usr/lib/mypad-${PV}/Modes
	doins $BINDIR/Modes/*.xshd

	elog "Preparing data directory"
	# actually this should be in the user home folder
	dodir /usr/lib/mypad-${PV}/Data

	elog "Configuring templating engine"
	# actually this should be in the user home folder
	dosym /usr/lib/mypad-${PV} /usr/lib/mypad-${PV}/bin
	insinto /usr/lib/mypad-${PV}
	doins $BINDIR/*.aspx
	doins $BINDIR/*.config

	elog "Installing desktop icon"
	local ICON_NAME=AtomFeedIcon.svg
	local FULL_ICON_NAME=MyPad/Resources/${ICON_NAME}
	newicon -s scalable "${FULL_ICON_NAME}" "${ICON_NAME}"
	make_desktop_entry "/usr/bin/mypad" "${DESCRIPTION}" "/usr/share/icons/hicolor/scalable/apps/${ICON_NAME}"
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
