# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac +nupkg developer debug doc"

inherit gac dotnet nupkg

NAME="Pliant"
HOMEPAGE="https://github.com/patrickhuber/${NAME}"
EGIT_COMMIT="dd03ca2942d999a8eb2e30a51b3ccf8d3c70602d"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="modified Earley parser in C# inspired by the Marpa Parser project"
LICENSE="MIT" # https://github.com/patrickhuber/Pliant/blob/master/LICENSE.md
KEYWORDS="~amd64 ~ppc ~x86"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply_user
}

src_compile() {
	exbuild_strong "libraries/Pliant/Pliant.csproj"
	#enuspec "libraries/Pliant/Pliant.nuspec"
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi
	egacinstall "libraries/Pliant/bin/${CONFIGURATION}/Pliant.dll"
	einstall_pc_file "${PN}" "${PV}" "Pliant"
	#enupkg
}
