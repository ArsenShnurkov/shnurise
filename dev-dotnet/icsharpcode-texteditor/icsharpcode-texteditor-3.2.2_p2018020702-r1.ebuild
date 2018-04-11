# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"
RESTRICT="mirror"
KEYWORDS="~amd64 ~x86 ~ppc"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkgconfig"

inherit eutils msbuild gac mono-pkg-config

DESCRIPTION="ICSharpCode.TextEditor library"
LICENSE="MIT"

PROJECTNAME="ICSharpCode.TextEditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="38c21a56f969047ef109b400ac5a57ca9df097fa"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}.zip
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

#DEPEND="|| ( >=dev-lang/mono-3.4.0 <dev-lang/mono-9999 )	"
RDEPEND="${DEPEND}"

METAFILETOBUILD="ICSharpCode.TextEditor.sln"
ASSEMBLY_NAME="ICSharpCode.TextEditor"
ASSEMBLY_VERSION="${PV}"

KEY2="${DISTDIR}/mono.snk"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "Project/bin/${DIR}/${ASSEMBLY_NAME}.dll"
}

src_compile() {
	emsbuild "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" "${METAFILETOBUILD}"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	elib "$(output_filename)"

	insinto "/gac"
	doins "$(output_filename)"
}

pkg_preinst()
{
	echo mv "${D}/gac/${ASSEMBLY_NAME}.dll" "${T}/${ASSEMBLY_NAME}.dll"
	mv "${D}/gac/${ASSEMBLY_NAME}.dll" "${T}/${ASSEMBLY_NAME}.dll" || die
	echo rm -rf "${D}/gac"
	rm -rf "${D}/gac" || die
}

pkg_postinst()
{
	egacadd "${T}/${ASSEMBLY_NAME}.dll"
	rm "${T}/${ASSEMBLY_NAME}.dll" || die
}

pkg_prerm()
{
	egacdel "${ASSEMBLY_NAME}, Version=${ASSEMBLY_VERSION}, Culture=neutral, PublicKeyToken=0738eb9f132ed756"
}
