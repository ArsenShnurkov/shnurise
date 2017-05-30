# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
inherit mono-env gac nupkg

NAME="NUnit.System.Linq"
HOMEPAGE="https://github.com/nunit/${NAME}"

EGIT_COMMIT="e8c70639092dea64f76105fbccb9a6d6185a5f8f"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT="3"

DESCRIPTION="Partial implementation of System.Linq for use with NUnit's .NET 2.0 builds"
LICENSE="MIT" # https://github.com/nunit/nunit/blob/master/LICENSE.txt
KEYWORDS="~amd64 ~x86"
#USE_DOTNET="net20 net40 net45"
USE_DOTNET="net45"
IUSE="+net45 developer debug nupkg gac doc"

CDEPEND=">=dev-lang/mono-4.0.2.5
	net45? (
		developer? (
			debug?  ( dev-dotnet/cecil[net45,gac,developer,debug] )
			!debug? ( dev-dotnet/cecil[net45,gac,developer] )
		)
		!developer? (
			debug?  ( dev-dotnet/cecil[net45,gac,debug] )
			!debug? ( dev-dotnet/cecil[net45,gac] )
		)
	)
"

DEPEND="${CDEPEND}
	net45? (
		developer? (
			debug? ( dev-util/nant[net45,nupkg,developer,debug] )
			!debug? ( dev-util/nant[net45,nupkg,developer] )
		)
		!developer? (
			debug? ( dev-util/nant[net45,nupkg,debug] )
			!debug? ( dev-util/nant[net45,nupkg] )
		)
	)
"

RDEPEND="${CDEPEND}
"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
FILE_TO_BUILD=NUnit.System.Linq.sln
METAFILETOBUILD="${S}/${FILE_TO_BUILD}"

NUGET_PACKAGE_VERSION="$(get_version_component_range 1-3)"

src_prepare() {
	default
}

src_compile() {
	exbuild "${METAFILETOBUILD}"
}

src_install() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi

	SLOTTEDDIR="/usr/share/nunit-${SLOT}/"
	insinto "${SLOTTEDDIR}"
	doins bin/${DIR}/*.{config,dll,exe}
	# install: cannot stat 'bin/Release/*.mdb': No such file or directory
	if use developer; then
		doins bin/${DIR}/*.mdb
	fi

	if use doc; then
		doins LICENSE.txt NOTICES.txt CHANGES.txt
	fi
}
