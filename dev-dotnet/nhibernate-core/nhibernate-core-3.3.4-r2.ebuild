# Copyright 1999-2012 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="amd64 ~x86"
RESTRICT="mirror"

SLOT="3"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +msbuild debug developer doc"

inherit mpt-r20150903
inherit msbuild mono-pkg-config gac

GITHUB_REPOSITORY_NAME="nhibernate-core"
GITHUB_ACCOUNT_NAME="nhibernate"
HOMEPAGE="https://github.com/${GITHUB_ACCOUNT_NAME}/${GITHUB_REPOSITORY_NAME}"
EGIT_COMMIT="78ee78d7863300c791ff86df00f94072e83537dc"
SRC_URI="https://github.com/${GITHUB_ACCOUNT_NAME}/${GITHUB_REPOSITORY_NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${GITHUB_REPOSITORY_NAME}-${EGIT_COMMIT}"

DESCRIPTION="NHibernate Object Relational Mapper"
LICENSE="LGPL-2.1" # https://github.com/nhibernate/nhibernate-core/blob/master/LICENSE.txt

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
	dev-dotnet/antlr3-runtime:31
	dev-dotnet/nhibernate-iesi-collections
	dev-dotnet/remotion-linq
	dev-dotnet/remotion-linq-eagerfetching
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-util/antlrcs
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

KEY1="${DISTDIR}/mono.snk"
KEY1_TOKEN="0738eb9f132ed756"
KEY2="${DISTDIR}/mono.snk"
KEY2_TOKEN="0738eb9f132ed756"

PATH_TO_PROJ="src/NHibernate"
METAFILE_NAME="NHibernate.csproj"
ASSEMBLY_NAME="NHibernate"
ASSEMBLY_VER="${PV}"

function output_filename ( ) {
	echo "${PATH_TO_PROJ}/bin/$(usedebug_tostring)/${ASSEMBLY_NAME}.dll"
}

function deploy_dir ( ) {
	echo "/usr/$(get_libdir)/mono/${EBUILD_FRAMEWORK}"
}

src_prepare() {
	cp "${FILESDIR}/SharedAssemblyInfo-${PV}.cs" "${S}/${PATH_TO_PROJ}/AssemblyInfo.cs" || die
	empt-csproj --remove-reference="Antlr3.Runtime" "${S}/${PATH_TO_PROJ}/${METAFILE_NAME}"
	empt-csproj --inject-reference="Antlr3.Runtime" --package-hintpath="/usr/share/dev-dotnet/antlr3-runtime-31/Antlr3.Runtime.dll" "${S}/${PATH_TO_PROJ}/${METAFILE_NAME}"
	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY1}" "${S}/${PATH_TO_PROJ}/${METAFILE_NAME}"
	sn -R "${S}/$(output_filename)" "${KEY2}" || die
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
	egacdel "${ASSEMBLY_NAME}, Version=${ASSEMBLY_VER}, Culture=neutral, PublicKeyToken=${KEY1_TOKEN}"
}
