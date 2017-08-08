# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
KEYWORDS="~amd64 ~ppc ~x86"
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac dotnet

#https://github.com/mono/linux-packaging-msbuild/commit/0d8cee3f87b92cff425306d9c588fc6433fb6bf0
GITHUB_ACCOUNT="mono"
GITHUB_PROJECTNAME="linux-packaging-msbuild"
EGIT_COMMIT="0d8cee3f87b92cff425306d9c588fc6433fb6bf0"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> msbuild-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/mono/linux-packaging-msbuild"
DESCRIPTION="msbuild libraries for writing Task-derived classes"
LICENSE="MIT" # https://github.com/mono/linux-packaging-msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

UT_PROJ=Microsoft.Build.Utilities
FW_PROJ=Microsoft.Build.Framework
UT_DIR=src/Utilities
FW_DIR=src/Framework

src_prepare() {
	cp "${FILESDIR}/mono-${FW_PROJ}.csproj" "${FW_DIR}/" || die
	cp "${FILESDIR}/mono-${UT_PROJ}.csproj" "${UT_DIR}/" || die
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

	VER=15.3.0.0
	KEY="${S}/mono/facades/mono.snk"

	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${FW_DIR}/mono-${FW_PROJ}.csproj"
	sn -R "${FW_DIR}/bin/${CONFIGURATION}/${FW_PROJ}.dll" "${KEY}" || die
	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${UT_DIR}/mono-${UT_PROJ}.csproj"
	sn -R "${UT_DIR}/bin/${CONFIGURATION}/${UT_PROJ}.dll" "${KEY}" || die
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	egacinstall "${FW_DIR}/bin/${CONFIGURATION}/${FW_PROJ}.dll"
	egacinstall "${UT_DIR}/bin/${CONFIGURATION}/${UT_PROJ}.dll"
	einstall_pc_file "${PN}" "${PV}" "${FW_PROJ}" "${UT_PROJ}"
}
