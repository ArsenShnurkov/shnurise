# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="3"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer symlink"

#inherit eutils
inherit dotnet
inherit gnome2-utils 

DESCRIPTION="mypad text editor"
LICENSE="MIT"

PROJECTNAME="mypad-winforms-texteditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="7be2a4923a4fe915f2c0cd3c7fb112062bf12a28"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${CATEGORY}-${PN}-${PV}.zip"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

ALLPEND="
	>=dev-dotnet/icsharpcode-texteditor-3.2.2_p2018020702-r1
	>=dev-dotnet/ndepend-path-0.0_p20151123-r1
	"

# The DEPEND ebuild variable should specify any dependencies which are 
# required to unpack, patch, compile or install the package
DEPEND="${ALLPEND}
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

function csproj_1() {
	echo  "${PROJECT1_PATH}/${PROJECT1_NAME}.csproj"
}

function install_dir() {
	echo "/usr/lib/mypad-${SLOT}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

src_prepare() {
	# default initialization
	eapply_user
}

src_compile() {
	:;
}

src_install() {
	local BINDIR=MyPad/bin/$(usedebug_tostring)

	elog "Installing executable"
	insinto "$(install_dir)"
	newins "${BINDIR}/MyPad.exe" MyPad${APPENDIX}.exe
	if use debug; then
		make_wrapper mypad${APPENDIX} "mono --debug $(install_dir)/MyPad.exe"
	else
		make_wrapper mypad${APPENDIX} "mono $(install_dir)/MyPad.exe"
	fi

	elog "Installing syntax coloring schemes for editor ${S}/${BINDIR}/Modes/*.xshd"
	dodir "$(install_dir)/Modes"
	insinto "$(install_dir)/Modes"
	doins "${S}/${BINDIR}/Modes/"*.xshd

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
