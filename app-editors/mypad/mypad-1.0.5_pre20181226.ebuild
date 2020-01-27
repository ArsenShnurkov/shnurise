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

DEPEND="
	>=dev-dotnet/icsharpcode-texteditor-3.2.2_p2018020702-r1
	>=dev-dotnet/ndepend-path-0.0_p20151123-r1
	"
RDEPEND="${DEPEND}	"

if [ "${SLOT}" != "0" ]; then
	APPENDIX="-${SLOT}"
fi

PROJECT_REL_DIR="MyPad"
ASSEMBLY_NAME=MyPad

function bin_dir ( ) {
	echo "${WORKDIR}/bin/$(usedebug_tostring)"
}

function output_arguments ( ) {
	local OUTPUT_TYPE="exe" # https://docs.microsoft.com/ru-ru/dotnet/csharp/language-reference/compiler-options/target-exe-compiler-option
	local OUTPUT_NAME="$(bin_dir)/${ASSEMBLY_NAME}.exe"
	echo  "/target:${OUTPUT_TYPE}" "/out:${OUTPUT_NAME}"
}

function references() {
	local REF1=""
	local REF2=""
	echo -n " " /reference:/usr/share/mono/assemblies/icsharpcode-texteditor/ICSharpCode.TextEditor.dll
	echo -n " " /reference:/usr/share/mono/assemblies/ndepend-path-1/NDepend.Path.dll
	echo -n " " /reference:System.dll
	echo -n " " /reference:System.Core.dll
	echo -n " " /reference:System.Drawing.dll
	echo -n " " /reference:System.Windows.Forms.dll
	echo -n " " /reference:System.Xml.dll
	echo -n " " /reference:System.Runtime.Remoting.dll
	echo -n " " /reference:System.Web.dll
	echo -n " " /reference:System.Configuration.dll
	echo -n " " /reference:System.ServiceModel.dll
}

function install_dir() {
	echo "/usr/lib/mypad-${SLOT}"
}

pkg_preinst() {
	gnome2_icon_savelist
}

src_prepare(){
	rm "${S}/MyPad/PluginManager.cs" || die
	rm "${S}/MyPad/Dialogs/PluginManagerDialog.cs" || die
	rm "${S}/MyPad/Dialogs/PluginManagerDialog.Designer.cs" || die
	rm "${S}/MyPad/VistaTreeView.cs" || die
	rm "${S}/MyPad/FileBrowser.Designer.cs" || die
	rm "${S}/MyPad/FileBrowser.cs" || die
	rm "${S}/MyPad/RPC_for_SingleInstance/WcfNetPipe.Engine.cs" || die
	rm "${S}/MyPad/RPC_for_SingleInstance/WcfHttp.Engine.cs" || die
	sed -i ' /using MyPad.Plugins;/d' "${S}/MyPad/EditorWindow.cs" || die
	eapply_user
}

src_compile() {
	mkdir -p $(bin_dir) || die
	/usr/bin/csc $(references)  $(csharp_sources "${S}/${PROJECT_REL_DIR}") $(output_arguments) || die
}

src_install() {
	elog "Installing executable"
	insinto "$(install_dir)"
	newins "$(bin_dir)/MyPad.exe" MyPad${APPENDIX}.exe
	if use debug; then
		make_wrapper mypad${APPENDIX} "mono --debug $(install_dir)/MyPad.exe"
	else
		make_wrapper mypad${APPENDIX} "mono $(install_dir)/MyPad.exe"
	fi

	elog "Installing syntax coloring schemes for editor ${S}/$(bin_dir)/Modes/*.xshd"
	dodir "$(install_dir)/Modes"
	insinto "$(install_dir)/Modes"
	doins "${S}/$(bin_dir)/Modes/"*.xshd

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
