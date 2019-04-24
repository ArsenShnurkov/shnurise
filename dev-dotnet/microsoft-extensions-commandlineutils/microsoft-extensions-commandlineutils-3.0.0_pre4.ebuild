# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} +gac debug developer"

inherit xbuild
inherit gac

GITHUB_ACCOUNT="aspnet"
GITHUB_REPONAME="Extensions"
HOMEPAGE="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}"
EGIT_COMMIT="fd0366daae4c9d47eba72ea6034002cbd7492018"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/ecma.pub
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
	"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

DESCRIPTION="A library for parsing command line parameters"
LICENSE="Apache-2.0" # https://github.com/aspnet/Extensions/blob/master/LICENSE.txt

PROJ1_DIR="src/Shared/src/CommandLineUtils"
PROJ1_NAME="Microsoft.Extensions.CommandLineUtils"

KEY1="${DISTDIR}/ecma.pub"
KEY2="${DISTDIR}/mono.snk"

src_prepare () {
	cp "${FILESDIR}/${PROJ1_NAME}.csproj" "${S}/${PROJ1_DIR}" || die
	# https://wiki.gentoo.org/wiki//etc/portage/patches
	eapply_user
}

src_compile () {
	exbuild_strong /tv:14.0 /p:TargetFrameworkVersion=v4.6 /p:AssemblyOriginatorKeyFile=${KEY1} "${S}/${PROJ1_DIR}/${PROJ1_NAME}.csproj"
	sn -R "${S}/${PROJ1_DIR}/bin/$(usedebug_tostring)/${PROJ1_NAME}.dll" "${KEY2}" || die
}

src_install () {
	egacinstall "${S}/${PROJ1_DIR}/bin/$(usedebug_tostring)/${PROJ1_NAME}.dll"
}
