# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
RESTRICT="mirror"
KEYWORDS="~amd64 ~x86 ~ppc"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkgconfig debug"

# inherit eutils 
inherit dotnet
inherit mono-pkg-config

DESCRIPTION="ICSharpCode.TextEditor library"
LICENSE="LGPL-2.1" # https://github.com/gitextensions/ICSharpCode.TextEditor/issues/18
 
PROJECTNAME="ICSharpCode.TextEditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="38c21a56f969047ef109b400ac5a57ca9df097fa"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}.zip"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

ASSEMBLY_NAME="ICSharpCode.TextEditor"
ASSEMBLY_VERSION="${PV}"

function obj_dir ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${WORKDIR}/obj/${DIR}"
}

function bin_dir ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${WORKDIR}/bin/${DIR}"
}

function output_filename ( ) {
	echo "$(bin_dir)/${ASSEMBLY_NAME}.dll"
}

src_compile() {
	einfo "Compiling code files"
	mkdir -p $(bin_dir) || die
	local NAMESPACE=ICSharpCode.TextEditor.Resources.
	csc /t:library ${S}/Project/**/*.cs \
		/resource:${S}/Project/Resources/RightArrow.cur,${NAMESPACE}RightArrow.cur \
		/resource:${S}/Project/Resources/TextEditorControl.bmp,${NAMESPACE}TextEditorControl.bmp \
		/resource:${S}/Project/Resources/SyntaxModes.xml,${NAMESPACE}SyntaxModes.xml \
		/resource:${S}/Project/Resources/Mode.xsd,${NAMESPACE}Mode.xsd \
		/resource:${S}/Project/Resources/HTML-Mode.xshd,${NAMESPACE}HTML-Mode.xshd \
		/resource:${S}/Project/Resources/XML-Mode.xshd,${NAMESPACE}XML-Mode.xshd \
		/resource:${S}/Project/Resources/CSharp-Mode.xshd,${NAMESPACE}CSharp-Mode.xshd \
		/resource:${S}/Project/Resources/ASPX.xshd,${NAMESPACE}ASPX.xshd \
		/resource:${S}/Project/Resources/Patch-Mode.xshd,${NAMESPACE}Patch-Mode.xshd \
		/resource:${S}/Project/Resources/Tex-Mode.xshd,${NAMESPACE}Tex-Mode.xshd \
		/resource:${S}/Project/Resources/BAT-Mode.xshd,${NAMESPACE}BAT-Mode.xshd \
		/resource:${S}/Project/Resources/CPP-Mode.xshd,${NAMESPACE}CPP-Mode.xshd \
		/resource:${S}/Project/Resources/JavaScript-Mode.xshd,${NAMESPACE}JavaScript-Mode.xshd \
		/resource:${S}/Project/Resources/Python-Mode.xshd,${NAMESPACE}Python-Mode.xshd \
		/resource:${S}/Project/Resources/Java-Mode.xshd,${NAMESPACE}Java-Mode.xshd \
		/resource:${S}/Project/Resources/PHP-Mode.xshd,${NAMESPACE}PHP-Mode.xshd \
		/resource:${S}/Project/Resources/VBNET-Mode.xshd,${NAMESPACE}VBNET-Mode.xshd \
		/resource:${S}/Project/Resources/Boo.xshd,${NAMESPACE}Boo.xshd \
		/resource:${S}/Project/Resources/Coco-Mode.xshd,${NAMESPACE}Coco-Mode.xshd \
		/out:$(output_filename) || die
}

src_install() {
	local INSTALL_DIR="$(anycpu_current_assembly_dir)"
	einfo "$(output_filename)" -\> "${INSTALL_DIR}"
	insinto "${INSTALL_DIR}"

	elib "${INSTALL_DIR}" "$(output_filename)"

	dosym "${INSTALL_DIR}/${ASSEMBLY_NAME}.dll" "$(anycpu_current_symlink_dir)/${ASSEMBLY_NAME}.dll"
}
