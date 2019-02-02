# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
RESTRICT="mirror"
KEYWORDS="~amd64 ~x86 ~ppc"

# see docs:
# https://github.com/gentoo/gentoo/commit/59a1a0dda7300177a263eb1de347da493f09fdee
# https://devmanual.gentoo.org/eclass-reference/eapi7-ver.eclass/index.html
inherit eapi7-ver
SLOT="$(ver_cut 1-2)"

VER="${SLOT}.0.0" # version of resulting .dll files in GAC

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit xbuild gac

GITHUB_ACCOUNT="Microsoft"
GITHUB_PROJECTNAME="msbuild"
EGIT_COMMIT="a0efa11be10d5209afc679d672a79ed67e27875a"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz
	"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/Microsoft/msbuild"
DESCRIPTION="msbuild libraries for writing Task-derived classes"
LICENSE="MIT" # https://github.com/mono/linux-packaging-msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

UT_PROJ=Microsoft.Build.Utilities
FW_PROJ=Microsoft.Build.Framework
UT_DIR=src/Utilities
FW_DIR=src/Framework

src_prepare() {
	mkdir -p "${S}/packages/msbuild/" || die
	cp "${FILESDIR}/MSFT.snk" "${S}/packages/msbuild/" || die
	cp "${FILESDIR}/mono.snk" "${S}/packages/msbuild/" || die
	eapply "${FILESDIR}/${PV}/ToolLocationHelper.cs.patch"
	cp "${FILESDIR}/${PV}/mono-${FW_PROJ}.csproj" "${S}/${FW_DIR}" || die
	cp "${FILESDIR}/${PV}/mono-${UT_PROJ}.csproj" "${S}/${UT_DIR}" || die
	eapply_user
}

src_compile() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	if use developer; then
		SARGS=DebugSymbols=True
	else
		SARGS=DebugSymbols=False
	fi

	KEY="${S}/packages/msbuild/MSFT.snk"
	KEY2="${S}/packages/msbuild/mono.snk"
	#KEY="${KEY2}"

	exbuild_raw /v:detailed /p:MonoBuild=true /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${FW_DIR}/mono-${FW_PROJ}.csproj"
	sn -R "${S}/src/Framework/bin/${CONFIGURATION}/${FW_PROJ}.dll" "${KEY2}" || die
	exbuild_raw /v:detailed /p:MonoBuild=true /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${UT_DIR}/mono-${UT_PROJ}.csproj"
	sn -R "${S}/src/Utilities/bin/${CONFIGURATION}/${UT_PROJ}.dll" "${KEY2}" || die
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	egacinstall "${S}//src/Framework/bin/${CONFIGURATION}/${FW_PROJ}.dll"
	egacinstall "${S}//src/Utilities/bin/${CONFIGURATION}/${UT_PROJ}.dll"
	# einstall_pc_file "${PN}" "${VER}" "${FW_PROJ}" "${UT_PROJ}"
}
