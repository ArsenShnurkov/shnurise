# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"
RESTRICT="mirror"
KEYWORDS="~amd64 ~x86"

SLOT="2"

USE_DOTNET="net45"
IUSE="${USE_DOTNET} debug developer symlink"

inherit eutils gnome2-utils
inherit msbuild

DESCRIPTION="mypad text editor"
LICENSE="MIT"

PROJECTNAME="mypad-winforms-texteditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="0cbef257aefa9dec1fdbbd0f98616fc461d58a75"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

ALLPEND="dev-lang/mono
	>=dev-dotnet/icsharpcode-texteditor-3.2.2_p2018020702
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

if [ "${SLOT}" != "0" ]; then
	APPENDIX="-${SLOT}"
fi

PROJECT1_PATH="${S}/MyPad"
PROJECT1_NAME="MyPad"
PROJECT1_OUT="MyPad"

function install_dir() {
	echo "/usr/lib/mypad-${SLOT}"
}


pkg_preinst() {
	gnome2_icon_savelist
}

src_prepare() {
	eapply_user
}

src_compile() {
	# https://bugzilla.xamarin.com/show_bug.cgi?id=9340
	emsbuild /p:TargetFrameworkVersion=v4.6 "${PROJECT1_PATH}/${PROJECT1_NAME}.csproj"
}

src_install() {
	local BINDIR=""
	if use debug; then
		BINDIR=MyPad/bin/Debug
	else
		BINDIR=MyPad/bin/Release
	fi

	elog "Installing executable"
	insinto "$(install_dir)"
	newins "${BINDIR}/MyPad.exe" MyPad${APPENDIX}.exe
	if use debug; then
		make_wrapper mypad${APPENDIX} "mono --debug $(install_dir)/MyPad.exe"
	else
		make_wrapper mypad${APPENDIX} "mono $(install_dir)/MyPad.exe"
	fi

	elog "Installing syntax coloring schemes for editor"
	dodir "$(install_dir)/Modes"
	insinto /usr/lib/mypad-${PV}/Modes
	doins "$BINDIR/Modes/*.xshd"

	elog "Preparing data directory"
	# actually this should be in the user home folder
	dodir "$(install_dir)/Data"

	elog "Configuring templating engine"
	# actually this should be in the user home folder
	dosym $(install_dir) $(install_dir)/bin
	insinto "$(install_dir)"
	doins $BINDIR/*.aspx
	doins $BINDIR/*.config

	elog "Installing desktop icon"
	local ICON_NAME="AtomFeedIcon.svg"
	local FULL_ICON_NAME="MyPad/Resources/${ICON_NAME}"
	newicon -s scalable "${FULL_ICON_NAME}" "${ICON_NAME}"
	make_desktop_entry "/usr/bin/mypad${APPENDIX}" "${DESCRIPTION}" "/usr/share/icons/hicolor/scalable/apps/${ICON_NAME}"
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}
