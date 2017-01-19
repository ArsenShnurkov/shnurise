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
	>=dev-util/mono-packaging-tools-1.4.1.6
"

src_prepare() {
	#eapply "${FILESDIR}/remove-warnings-as-errors-${PV}.patch"
	#eapply "${FILESDIR}/add-version-property-handling.patch"
	mpt-csproj --remove-warnings-as-errors ./src || die "removing warning-as-error failed"
	mpt-csproj --remove-signing ./src || die "removing signing failed"
	eapply_user
}

src_compile() {
	exbuild_strong /p:VersionNumber=${PV}.0 \
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
