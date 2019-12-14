# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="~x86 ~amd64"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug +pkg-config +symlink"

inherit dotnet
inherit mono-pkg-config

NAME="NDepend.Path"

DESCRIPTION="C# framework for paths operations: Absolute, Drive Letter, UNC, Relative, prefix"
LICENSE="MIT" # https://github.com/psmacchia/NDepend.Path/blob/master/LICENSE
HOMEPAGE="https://github.com/psmacchia/${NAME}"
EGIT_COMMIT="96008fcfbc137eac6fd327387b80b14909a581a1"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

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
	:;
}

src_install() {
	:;
}
