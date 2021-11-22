# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="amd64 ~arm64"
RESTRICT="mirror"

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
USE_DOTNET="net45"
IUSE="${USE_DOTNET} +gac +pkg-config debug developer test symlink"

inherit msbuild mono-pkg-config

# no need to inherit "gac", because it is inherited from "machine"
inherit gac
# inherit machine

NAME="npgsql"
NUSPEC_ID="${NAME}"
HOMEPAGE="https://github.com/npgsql/${NAME}"

EGIT_COMMIT="ecfb8b2c4bc5108e40c990b83c2863c61f7ef8b4"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	gac? ( https://github.com/mono/mono/raw/master/mcs/class/mono.snk )"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="0"

DESCRIPTION="allows any program developed for .NET framework to access a PostgreSQL database"
LICENSE="npgsql"
LICENSE_URL="https://github.com/npgsql/npgsql/blob/develop/LICENSE.txt"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )
"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
	test? ( dev-util/nunit2 )
"

PROJECT1_PATH=src/Npgsql
PROJECT1_NAME=Npgsql
PROJECT1_OUT=Npgsql

NPGSQL_CSPROJ=src/Npgsql/Npgsql.csproj
METAFILETOBUILD=${NPGSQL_CSPROJ}

src_prepare() {
	default
	sed "s/\$(OutputType)/Library/; s/\$(AssemblyName)/${PROJECT1_OUT}/" "${FILESDIR}/template.csproj" > "${S}/${PROJECT1_PATH}/${PROJECT1_NAME}.csproj" || die
}

src_compile() {
	emsbuild  /p:DefineConstants=NET451 /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${DISTDIR}/mono.snk" "${METAFILETOBUILD}"
	if use test; then
		exbuild /p:SignAssembly=true "/p:AssemblyOriginatorKeyFile=${DISTDIR}/mono.snk" "test/Npgsql.Tests/Npgsql.Tests.csproj"
	fi
}

src_install() {
	FINAL_DLL=src/Npgsql/bin/$(usedebug_tostring)/Npgsql.dll

	insinto ${PREFIX}/usr/lib/mono/${EBUILD_FRAMEWORK}
	doins ${FINAL_DLL}

	einstall_pc_file "${PN}" "${PV}" "Npgsql"
}

pkg_postinst()
{
	egacadd "${PREFIX}/usr/lib/mono/${EBUILD_FRAMEWORK}/Npgsql.dll"
#	emachineadd "Npgsql" "Npgsql Data Provider" "${PREFIX}/usr/lib/mono/${EBUILD_FRAMEWORK}/Npgsql.dll"
}

pkg_prerm()
{
	emachinedel "Npgsql" "Npgsql Data Provider" "${PREFIX}/usr/lib/mono/${EBUILD_FRAMEWORK}/Npgsql.dll"
#	egacdel "Npgsql"
}