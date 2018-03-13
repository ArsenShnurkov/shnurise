# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="6"

KEYWORDS="~x86 ~amd64"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug +pkg-config +symlink"

inherit msbuild gac mpt-r20150903 mono-pkg-config

DESCRIPTION="C# framework for paths operations: Absolute, Drive Letter, UNC, Relative, prefix"
LICENSE="MIT"
NAME="NDepend.Path"
HOMEPAGE="https://github.com/psmacchia/${NAME}"
EGIT_COMMIT="96008fcfbc137eac6fd327387b80b14909a581a1"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

CDEPEND=""
DEPEND="${CDEPEND}
	>=dev-util/mono-packaging-tools-1.4.4.4"
RDEPEND="${CDEPEND}"

DLLNAME=${NAME}
FULLSLN=${NAME}.sln

src_prepare() {
	sed -i "/AllRules.ruleset/d" "${S}/${NAME}/${NAME}.csproj"
	empt-csproj --dir="${S}/${NAME}" --remove-signing
	empt-csproj --dir="${S}/${NAME}" --remove-reference "Microsoft.Contracts"
	empt-sln --sln-file "${S}/${FULLSLN}" --remove-proj "NDepend.Path.Tests"

	rm "${S}/NDepend.Path/NDepend.Helpers/IReadOnlyList.cs" || die
	sed -i "/IReadOnlyList.cs/d" "${S}/${NAME}/${NAME}.csproj"
	
	sed -i '1 i\using System.Collections.Generic;' NDepend.Path/NDepend.Path/PathHelpers.cs || die

	eapply_user
}

src_compile() {
	emsbuild /p:TargetFrameworkVersion=v4.6 "${FULLSLN}"
}

src_install() {
	elib "${NAME}/bin/$(usedebug_tostring)/${DLLNAME}.dll"
}
