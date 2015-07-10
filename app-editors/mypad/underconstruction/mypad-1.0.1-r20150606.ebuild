# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils dotnet

DESCRIPTION="mypad text editor"
LICENSE="MIT"

PROJECTNAME="mypad-winforms-texteditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="d1b91ee444ded73c4a3840e481cd41a521c02bee"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"

SLOT="0"
IUSE="debug"

KEYWORDS="amd64 ppc x86"

ALLPEND="|| ( >=dev-lang/mono-4 <dev-lang/mono-9999 )
	dev-dotnet/icsharpcodetexteditor
	"

# The DEPEND ebuild variable should specify any dependencies which are 
# required to unpack, patch, compile or install the package
DEPEND="${ALLPEND}
	dev-dotnet/nuget
	"

# The RDEPEND ebuild variable should specify any dependencies which are 
# required at runtime. 
# when installing from a binary package, only RDEPEND will be checked.
RDEPEND="${ALLPEND}
	"


S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

# METAFILETOBUILD=${PROJECTNAME}.sln
METAFILETOBUILD=MyPad.sln

src_prepare() {
	elog "Patching"
#	elog "NuGet restore"
#	/usr/bin/nuget restore ${METAFILETOBUILD} || die
}

src_compile() {
	# https://bugzilla.xamarin.com/show_bug.cgi?id=9340
	if use debug; then
		exbuild /p:DebugSymbols=True ${METAFILETOBUILD}
	else
		exbuild /p:DebugSymbols=False ${METAFILETOBUILD}
	fi
}

src_install() {
	elog "Installing executable"
	insinto /usr/lib/mypad/
	make_wrapper mypad "mono /usr/lib/mypad/mypad.exe"
}
