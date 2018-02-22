# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

KEYWORDS="~x86 ~amd64 ~ppc"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug"

inherit msbuild gac mpt-r20150903

DESCRIPTION="C# framework for paths operations: Absolute, Drive Letter, UNC, Relative, prefix"
LICENSE="MIT"
NAME="NDepend.Path"
HOMEPAGE="https://github.com/psmacchia/${NAME}"
EGIT_COMMIT="96008fcfbc137eac6fd327387b80b14909a581a1"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

CDEPEND=""
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

DLLNAME=${NAME}
FULLSLN=${NAME}.sln

src_prepare() {
	sed -i "/AllRules.ruleset/d" "${S}/${NAME}/${NAME}.csproj"
	empt-csproj --dir="${S}/${NAME}" --remove-reference "Microsoft.Contracts"
	empt-sln --sln-file "${S}/${FULLSLN}" --remove-proj "NDepend.Path.Tests"

	rm "${S}/NDepend.Path/NDepend.Helpers/IReadOnlyList.cs" || die
	sed -i "/IReadOnlyList.cs/d" "${S}/${NAME}/${NAME}.csproj"
	
	sed -i '1 i\using System.Collections.Generic;' NDepend.Path/NDepend.Path/PathHelpers.cs || die

	eapply_user
}

src_compile() {
	if use gac; then
		KEY2="${DISTDIR}/mono.snk"
		emsbuild "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" /p:TargetFrameworkVersion=v4.6 "${FULLSLN}"
	else
		emsbuild /p:TargetFrameworkVersion=v4.6 "${FULLSLN}"
	fi
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	sn -R "${NAME}/bin/${DIR}/${DLLNAME}.dll" "${KEY2}" || die
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	elog "Installing ${DLLNAME}.dll into GAC "
	egacinstall "${NAME}/bin/${DIR}/${DLLNAME}.dll"
}
