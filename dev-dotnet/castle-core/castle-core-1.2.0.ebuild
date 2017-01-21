# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"
SLOT="1"
USE_DOTNET="net45"

IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac dotnet

REPO_NAME="Castle.Core-READONLY"
EGIT_COMMIT="44859cac767ff02dfc43911c4ce4a571625648b0"
SRC_URI="https://github.com/castleproject/${REPO_NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${REPO_NAME}-${EGIT_COMMIT}"

HOMEPAGE="http://www.castleproject.org/"
DESCRIPTION="including Castle DynamicProxy, Logging Services and DictionaryAdapter "
LICENSE="Apache-2.0" # https://github.com/castleproject/Core/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/mono-packaging-tools-1.4.2.2
"

src_prepare() {
	mpt-csproj ./src --remove-warnings-as-errors || die "removing warning-as-error failed"
	mpt-csproj ./src --remove-signing || die "removing signing failed"
	mpt-csproj ./src --inject-import='$(MSBuildToolsPath)\MSBuild.Community.Tasks.Targets' || die "injecting import falied"
	mpt-csproj ./src --inject-versioning=VersionNumber || die "injecting versioning falied"
	# https://github.com/castleproject/Core/raw/master/buildscripts/CastleKey.snk
	mpt-csproj ./src/Castle.Core --inject-InternalsVisibleTo=Castle.Core.Tests --AssemblyOriginatorKeyFile=${FILESDIR}/CastleKey.snk || die
	eapply_user
}

src_compile() {
	exbuild /p:SignAssembly=true /p:AssemblyOriginatorKeyFile=${FILESDIR}/CastleKey.snk /p:VersionNumber=${PV}.0 \
		"/p:RootPath=${S}/src" "src/Core-vs2008.sln"
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi
	egacinstall "src/Castle.Core/bin/${CONFIGURATION}/Castle.Core.dll"
	einstall_pc_file "${PN}" "${PV}" "Castle.Core"
}
