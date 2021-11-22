# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="4"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +msbuild debug developer doc"

inherit msbuild mono-pkg-config gac

NAME="nhibernate-core"
HOMEPAGE="https://github.com/nhibernate/${NAME}"
EGIT_COMMIT="b64b6b74278a12a6a12e19e6a33f97fac6b6c910"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${NAME}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="NHibernate Object Relational Mapper"
LICENSE="LGPL-2.1" # https://github.com/nhibernate/nhibernate-core/blob/master/LICENSE.txt

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
	dev-dotnet/antlr3-runtime
	dev-dotnet/iesi-collections
	dev-dotnet/remotion-linq
	dev-dotnet/remotion-linq-eagetfetching
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/antlrcs
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

KEY1="${DISTDIR}/mono.snk"
KEY1_TOKEN="0738eb9f132ed756"
KEY2="${DISTDIR}/mono.snk"
KEY2_TOKEN="0738eb9f132ed756"

METAFILE_DIR="src/NHibernate"
METAFILE_NAME="NHibernate.csproj"
ASSEMBLY_NAME="NHibernate"
ASSEMBLY_VER="${PV}"

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "${METAFILE_DIR}/bin/${DIR}/${ASSEMBLY_NAME}.dll"
}

function deploy_dir ( ) {
	echo "/usr/$(get_libdir)/mono/${EBUILD_FRAMEWORK}"
}

src_prepare() {
	eapply "${FILESDIR}/${METAFILE_NAME}-${PV}.patch"
	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY1}" "${S}/${METAFILE_DIR}/${METAFILE_NAME}"
	sn -R "${S}/$(output_filename)" "${KEY2}" || die
}

src_install() {
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
	egacdel "${ASSEMBLY_NAME}, Version=${ASSEMBLY_VER}, Culture=neutral, PublicKeyToken=${KEY1_TOKEN}"
}
