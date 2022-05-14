# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net47"
IUSE="+${USE_DOTNET} +gac debug developer"

inherit xbuild
inherit gac

GITHUB_ACCOUNT="natemcmaster"
GITHUB_REPONAME="CommandLineUtils"
EGIT_COMMIT="cf83608801e780ef98f5fe1527ca141a6454cc36"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

HOMEPAGE="https://natemcmaster.github.io/CommandLineUtils/"
DESCRIPTION="Command line parsing and utilities for .NET Core and .NET Framework"
LICENSE="Apache-2.0" # https://github.com/aspnet/Extensions/blob/master/LICENSE.txt

PROJ1_DIR="src/CommandLineUtils"
PROJ1_NAME="Microsoft.Extensions.CommandLineUtils"

#KEY1="${DISTDIR}/ecma.pub"
#KEY2="${DISTDIR}/mono.snk"
KEY1="${S}/src/StrongName.snk"
KEY2="${KEY1}"

src_prepare () {
	cp "${FILESDIR}/${PROJ1_NAME}.csproj" "${S}/${PROJ1_DIR}" || die
	# https://wiki.gentoo.org/wiki//etc/portage/patches
	eapply_user
}

src_compile () {
	exbuild_strong /tv:14.0 /p:TargetFrameworkVersion=v4.7 /p:AssemblyOriginatorKeyFile=${KEY1} "${S}/${PROJ1_DIR}/${PROJ1_NAME}.csproj"
	sn -R "${S}/${PROJ1_DIR}/bin/$(usedebug_tostring)/${PROJ1_NAME}.dll" "${KEY2}" || die
}

src_install () {
	egacinstall "${S}/${PROJ1_DIR}/bin/$(usedebug_tostring)/${PROJ1_NAME}.dll"
}
