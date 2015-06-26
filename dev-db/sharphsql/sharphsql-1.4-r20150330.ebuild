# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet

DESCRIPTION="Small & embebdded database engine witten in C#, port of the Hypersonic SQL v1.4 (HSQL) Java project"

LICENSE="CDDL"   # LICENSE syntax is defined in https://wiki.gentoo.org/wiki/GLEP:23

SLOT="0"

IUSE="debug test gac nupkg"

PROJECTNAME="SharpHSQL"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="55734ef6c294207d07a1b220fd7f52899a3bc881"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"

KEYWORDS="~x86 ~amd64 ~ppc"
DEPEND="|| ( >=dev-lang/mono-3.12.0 <dev-lang/mono-9999 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

METAFILETOBUILD=${PROJECTNAME}.sln

src_compile() {
	# https://bugzilla.xamarin.com/show_bug.cgi?id=9340
	if use debug; then
		exbuild /p:DebugSymbols=True ${METAFILETOBUILD}
	else
		exbuild /p:DebugSymbols=False ${METAFILETOBUILD}
	fi
}

src_install() {
	if use gac; then
		elog "Installing assemblies"
		egacinstall src/SharpHSQL/bin/Release/SharpHsql.dll
#		doins Source/PashConsole/bin/Release/*.mdb
	fi
}
