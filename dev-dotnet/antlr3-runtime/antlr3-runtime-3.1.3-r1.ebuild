# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="31"

USE_DOTNET="net45"

IUSE="+${USE_DOTNET} debug developer doc"

inherit dotnet msbuild gac mono-pkg-config

GITHUB_ACCOUNT_NAME="antlr"
GITHUB_REPOSITORY_NAME="antlr3"
HOMEPAGE="https://github.com/antlr/${GITHUB_REPOSITORY_NAME}"
EGIT_COMMIT="69f890e6433edfce316f09f9fa6b7ebf20551344"
SRC_URI="https://github.com/${GITHUB_ACCOUNT_NAME}/${GITHUB_REPOSITORY_NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${GITHUB_REPOSITORY_NAME}-${EGIT_COMMIT}"

DESCRIPTION="The C# port of ANTLR 3 (Rubtime library)"
LICENSE="BSD" # https://github.com/antlr/antlrcs/blob/master/LICENSE.txt

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

PATH_TO_PROJ="runtime/CSharp2/Sources/Antlr3.Runtime"
METAFILE_TO_BUILD="Antlr3.Runtime.csproj"
ASSEMBLY_NAME="Antlr3.Runtime"

KEY2="${DISTDIR}/mono.snk"
ASSEMBLY_VERSION="3.1.3.0"

function output_filename ( ) {
	echo "${PATH_TO_PROJ}/bin/$(usedebug_tostring)/${ASSEMBLY_NAME}.dll"
}

src_prepare() {
	cp "${FILESDIR}/${METAFILE_TO_BUILD}" "${S}/${PATH_TO_PROJ}/" || die
	cp "${FILESDIR}/IAstRuleReturnScope\`1.cs" "${S}/${PATH_TO_PROJ}/Antlr.Runtime/" || die
	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" /p:VersionNumber="${ASSEMBLY_VERSION}" "${S}/${PATH_TO_PROJ}/${METAFILE_TO_BUILD}"
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
