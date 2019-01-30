# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
RESTRICT="mirror"
KEYWORDS="~amd64 ~x86 ~ppc"

VER="15.4.0.0"
SLOT="1"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit xbuild gac

GITHUB_ACCOUNT="Microsoft"
GITHUB_PROJECTNAME="msbuild"
EGIT_COMMIT="51c3830b82db41a313305d8ee5eb3e8860a5ceb5"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz"
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
	eapply "${FILESDIR}/${PV}/dir.props.diff"
	eapply "${FILESDIR}/${PV}/dir.targets.diff"
	eapply "${FILESDIR}/${PV}/src-dir.targets.diff"
	eapply "${FILESDIR}/${PV}/ToolLocationHelper.cs.patch"
#	sed -i 's/CurrentAssemblyVersion = "15.1.0.0"/CurrentAssemblyVersion = "'${PV}'"/g' "${S}/src/Shared/Constants.cs" || die
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