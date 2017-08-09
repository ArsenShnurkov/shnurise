# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
RESTRICT="mirror"
KEYWORDS="~amd64"
SLOT="0"

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac dotnet

GITHUB_ACCOUNT="mono"
GITHUB_PROJECTNAME="linux-packaging-msbuild"
EGIT_COMMIT="431c7ec5857a3ee5df758c09948719490025ef94"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://docs.microsoft.com/visualstudio/msbuild/msbuild"
DESCRIPTION="Microsoft Build Engine (MSBuild) is an XML-based platform for building applications"
LICENSE="MIT" # https://github.com/mono/linux-packaging-msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
	dev-dotnet/msbuild-tasks-api
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

PROJ1=Microsoft.Build
PROJ1_DIR=src/Build
PROJ2=MSBuild
PROJ2_DIR=src/MSBuild

src_prepare() {
	cp "${FILESDIR}/mono-${PROJ1}.csproj" "${S}/${PROJ1_DIR}/" || die
	cp "${FILESDIR}/mono-${PROJ2}.csproj" "${S}/${PROJ2_DIR}/" || die
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

	VER=1.0.27.0
	KEY="${FILESDIR}/mono.snk"

	# exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${PROJ1_DIR}/mono-${PROJ1}.csproj"
	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" /p:${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY}" "${S}/${PROJ2_DIR}/mono-${PROJ2}.csproj"
	sn -R "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll" "${KEY}" || die
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	egacinstall "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll"
	einstall_pc_file "${PN}" "${PV}" "${PROJ1}"

	insinto "/usr/share/${PN}"
	newins "${PROJ2_DIR}/bin/${CONFIGURATION}/${PROJ2}.exe" MSBuild.exe

	if use debug; then
		make_wrapper msbuild "/usr/bin/mono --debug /usr/share/${PN}/MSBuild.exe"
	else
		make_wrapper msbuild "/usr/bin/mono /usr/share/${PN}/MSBuild.exe"
	fi
}
