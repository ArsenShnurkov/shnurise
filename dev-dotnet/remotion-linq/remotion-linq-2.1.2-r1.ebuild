# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net46"

inherit msbuild mono-pkg-config gac

NAME="Relinq"
HOMEPAGE="https://github.com/re-motion/${NAME}"
EGIT_COMMIT="88b1055e0a737faff26c9d5e2789f520ac73ca86"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${NAME}-${PV}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Library to create full-featured LINQ providers."
LICENSE="Apache2.0" # https://github.com/re-motion/Relinq/blob/develop/license/Apache-2.0.txt

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

# https://github.com/re-motion/Relinq/blob/82fdca6a4bfd942bb4a71dd20ab9c5af0aea0541/How%20to%20build.txt
# We cannot provide the official remotion.snk keyfile, so you will need to create your own.
KEY2="${DISTDIR}/mono.snk"

METAFILE_FOR_BUILD="${S}/Core/Core.csproj"
DEPLOY_DIR="/usr/lib/mono/${EBUILD_FRAMEWORK}"

function assembly_name ( ) {
	echo "Remotion.Linq"
}

function output_filename ( ) {
	local DIR=""
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "Core/bin/${DIR}/$(assembly_name).dll"
}

src_prepare() {
	eapply "${FILESDIR}/Core.csproj.patch"
	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" "${METAFILE_FOR_BUILD}"
	sn -R "${S}/$(output_filename)" "${KEY2}" || die
}

src_install() {
	elib "$(output_filename)"

	insinto "/gac"
	doins "$(output_filename)"
}

pkg_preinst()
{
	echo mv "${D}/gac/$(assembly_name).dll" "${T}/$(assembly_name).dll"
	mv "${D}/gac/$(assembly_name).dll" "${T}/$(assembly_name).dll" || die
	echo rm -rf "${D}/gac"
	rm -rf "${D}/gac" || die
}

pkg_postinst()
{
	egacadd "${T}/$(assembly_name).dll"
	rm "${T}/$(assembly_name).dll" || die
}

pkg_prerm()
{
	egacdel "$(assembly_name), Version=2.1.0.0, Culture=neutral, PublicKeyToken=0738eb9f132ed756"
}
