# Copyright 1999-2020 ArsenShnurkov@github
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="3"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer symlink"

inherit dotnet
inherit desktop
inherit xdg-utils

DESCRIPTION="mypad text editor"
LICENSE="MIT"

PROJECTNAME="mypad-winforms-texteditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="c81a9bbef8d8a644e54ec39ccb76481a55d11fa3"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${CATEGORY}-${PN}-${PV}.zip"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

DEPEND="
	>=dev-dotnet/icsharpcode-texteditor-3.2.2_p2018020702-r1
	>=dev-dotnet/ndepend-path-0.0_p20151123-r1
	"
RDEPEND="${DEPEND}	"

function obj_dir ( ) {
	echo "${WORKDIR}/obj/$(usedebug_tostring)"
}

function bin_dir ( ) {
	echo "${WORKDIR}/bin/$(usedebug_tostring)"
}

function references1() {
	echo -n " " /reference:System.dll
}

function output_arguments1 ( ) {
	local OUTPUT_TYPE="library" # https://docs.microsoft.com/ru-ru/dotnet/csharp/language-reference/compiler-options/target-exe-compiler-option
	local OUTPUT_NAME="$(bin_dir)/MyPad.Plugins.dll"
	echo  "/target:${OUTPUT_TYPE}" "/out:${OUTPUT_NAME}"
}

function references2() {
	echo -n " " /reference:/usr/share/mono/assemblies/icsharpcode-texteditor/ICSharpCode.TextEditor.dll
	echo -n " " /reference:/usr/share/mono/assemblies/ndepend-path-1/NDepend.Path.dll
	echo -n " " /reference:$(bin_dir)/MyPad.Plugins.dll
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

function resgen_inputs() {
#	echo -n " " /useSourcePath ${S}/MyPad/
	echo -n " " /compile 
	echo -n " " ${S}/MyPad/MainForm.resx,MainForm.resources
	echo -n " " ${S}/MyPad/Properties/Resources.resx,Resources.resources
	echo -n " " ${S}/MyPad/Resources/AtomFeedIcon.resx,AtomFeedIcon.resources
	echo -n " " ${S}/MyPad/Dialogs/AboutDialog.resx,AboutDialog.resources
	echo -n " " ${S}/MyPad/Dialogs/FindDialog.resx,FindDialog.resources
	echo -n " " ${S}/MyPad/Dialogs/FindReplaceDialog.resx,FindReplaceDialog.resources
	echo -n " " ${S}/MyPad/Dialogs/OptionsDialog.resx,OptionsDialog.resources
	echo -n " " ${S}/MyPad/Dialogs/UnsavedDocumentsDialog.resx,UnsavedDocumentsDialog.resources
	echo -n " " ${S}/MyPad/Dialogs/InsertImageDialog.resx,InsertImageDialog.resources
	echo -n " " ${S}/MyPad/Dialogs/Syndication/EntriesListDialog.resx,EntriesListDialog.resources
}

function resources2() {
	local NAMESPACE=MyPad
	echo -n " " /resource:$(obj_dir)/MainForm.resources,${NAMESPACE}.MainForm.resources
	echo -n " " /resource:$(obj_dir)/Resources.resources,${NAMESPACE}.MainForm.Resources.resources
	echo -n " " /resource:$(obj_dir)/AtomFeedIcon.resources,Resources.AtomFeedIcon.resources
	echo -n " " /resource:$(obj_dir)/AboutDialog.resources,${NAMESPACE}.Dialogs.AboutDialog.resources
	echo -n " " /resource:$(obj_dir)/FindDialog.resources,${NAMESPACE}.Dialogs.FindDialog.resources
	echo -n " " /resource:$(obj_dir)/FindReplaceDialog.resources,${NAMESPACE}.Dialogs.FindReplaceDialog.resources
	echo -n " " /resource:$(obj_dir)/OptionsDialog.resources,${NAMESPACE}.Dialogs.OptionsDialog.resources
	echo -n " " /resource:$(obj_dir)/UnsavedDocumentsDialog.resources,${NAMESPACE}.Dialogs.UnsavedDocumentsDialog.resources
	echo -n " " /resource:$(obj_dir)/InsertImageDialog.resources,${NAMESPACE}.Dialogs.InsertImageDialog.resources
	echo -n " " /resource:$(obj_dir)/EntriesListDialog.resources,${NAMESPACE}.Dialogs.EntriesListDialog.resources
# raw binary resource streams
	echo -n " " /resource:${S}/MyPad/Resources/MethodIcon.png,${NAMESPACE}.MethodIcon.png
	echo -n " " /resource:${S}/MyPad/Resources/DefaultIcon.png,${NAMESPACE}.DefaultIcon.png
	echo -n " " /resource:${S}/MyPad/Resources/FunctionIcon.png,${NAMESPACE}.FunctionIcon.png
	echo -n " " /resource:${S}/MyPad/Resources/InterfaceIcon.png,${NAMESPACE}.InterfaceIcon.png
	echo -n " " /resource:${S}/MyPad/Resources/VariableIcon.png,${NAMESPACE}.VariableIcon.png
	echo -n " " /resource:${S}/MyPad/Resources/MyPadicon.png,${NAMESPACE}.MyPadicon.png
	echo -n " " /resource:${S}/MyPad/Resources/CloseIcon.png,${NAMESPACE}.CloseIcon.png
	echo -n " " /resource:${S}/MyPad/Resources/cross.png,${NAMESPACE}.cross.png
	echo -n " " /resource:${S}/MyPad/Resources/AtomFeedIcon.svg,${NAMESPACE}.AtomFeedIcon.svg
}

function output_arguments2 ( ) {
	local OUTPUT_TYPE="exe" # https://docs.microsoft.com/ru-ru/dotnet/csharp/language-reference/compiler-options/target-exe-compiler-option
	local OUTPUT_NAME="$(bin_dir)/MyPad.exe"
	echo  "/target:${OUTPUT_TYPE}" "/out:${OUTPUT_NAME}"
}

function install_dir() {
	echo "/usr/lib/mypad-${SLOT}"
}

pkg_preinst() {
	#gnome2_icon_savelist
	:;
}

src_prepare(){
#	sed -i ' /using MyPad.Plugins;/d' "${S}/MyPad/EditorWindow.cs" || die
	eapply_user
}

src_compile() {
	mkdir -p $(bin_dir) || die
einfo === 1 ===
	einfo /usr/bin/csc $(references1)  $(csharp_sources "${S}/MyPad.Plugins") $(output_arguments1)
	/usr/bin/csc $(references1)  $(csharp_sources "${S}/MyPad.Plugins") $(output_arguments1) || die- dlloutput_N

einfo === 2 ===
	mkdir -p "$(obj_dir)" || die
	cd "$(obj_dir)" || die
	einfo /usr/bin/resgen $(resgen_inputs)
	/usr/bin/resgen $(resgen_inputs) || die
einfo === 3 ===
	einfo /usr/bin/csc /usr/bin/csc $(references2)  $(csharp_sources "${S}/MyPad") $(resources2) $(output_arguments2)
	/usr/bin/csc $(references2)  $(csharp_sources "${S}/MyPad") $(resources2) $(output_arguments2) || die
}

src_install() {
	elog "Installing executable"
	insinto "$(install_dir)"
	doins "$(bin_dir)/MyPad.exe"
	doins "$(bin_dir)/MyPad.Plugins.dll"
	newins "${S}/MyPad/app.config" "MyPad.exe.config"
	dosym "/usr/share/mono/assemblies/icsharpcode-texteditor/bin/ICSharpCode.TextEditor.dll" "$(install_dir)/ICSharpCode.TextEditor.dll"
	dosym "/usr/share/mono/assemblies/ndepend-path-1/bin/NDepend.Path.dll" "$(install_dir)/NDepend.Path.dll"

	elog "Configuring templating engine"
	# actually this should be in the user home folder
	dodir "$(install_dir)/bin"
#	dosym "/usr/share/mono/assemblies/icsharpcode-texteditor/bin/ICSharpCode.TextEditor.dll" "$(install_dir)/bin/ICSharpCode.TextEditor.dll"
#	dosym "/usr/share/mono/assemblies/ndepend-path-1/bin/NDepend.Path.dll" "$(install_dir)/bin/NDepend.Path.dll"
	dosym "../MyPad.exe"  "$(install_dir)/bin/MyPad.exe"
	doins "${S}/MyPad/Text1.aspx"
	doins "${S}/MyPad/web.config"

	elog "Installing syntax coloring schemes for editor ${S}/$(bin_dir)/Modes/*.xshd"
	dodir "$(install_dir)/Modes"
	insinto "$(install_dir)/Modes"
	doins "${S}/MyPad/Modes/"*.xshd

	elog "Preparing data directory"
	# actually this should be in the user home folder
	dodir "$(install_dir)/Data"

	elog "Installing desktop icon"
	local ICON_NAME="AtomFeedIcon.svg"
	local FULL_ICON_NAME="MyPad/Resources/${ICON_NAME}"
	newicon -s scalable "${FULL_ICON_NAME}" "${ICON_NAME}"
	make_desktop_entry "/usr/bin/mypad${APPENDIX}" "${DESCRIPTION}" "/usr/share/icons/hicolor/scalable/apps/${ICON_NAME}"

	# it is here because in src_install it gives the message
	# cannot change ownership of '.../image/usr/bin/mypad-3': Operation not permitted
	if use debug; then
		einfo make_wrapper mypad${APPENDIX} "mono --debug $(install_dir)/MyPad.exe"
		make_wrapper mypad${APPENDIX} "mono --debug $(install_dir)/MyPad.exe"
	else
		einfo make_wrapper mypad${APPENDIX} "mono $(install_dir)/MyPad.exe"
		make_wrapper mypad${APPENDIX} "mono $(install_dir)/MyPad.exe"
	fi
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
