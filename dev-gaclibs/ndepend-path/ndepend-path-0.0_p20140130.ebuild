# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit git-2 dotnet

DESCRIPTION="C# framework to handle all sorts of paths operations: File, Directory, Absolute, Drive Letter, UNC, Relative, prefixed"
LICENSE="MIT"
HOMEPAGE="https://github.com/psmacchia/NDepend.Path"
EGIT_REPO_URI="https://github.com/psmacchia/NDepend.Path.git"
EGIT_BRANCH="master"
EGIT_COMMIT="43498e0ca82876cc8b7023db10cad420f81484dc"
SRC_URI=""

SLOT="0"
IUSE="debug"
KEYWORDS="~x86 ~amd64 ~ppc"
DEPEND="|| ( >=dev-lang/mono-3.4.0 <dev-lang/mono-9999 )"
RDEPEND="${DEPEND}"

PATCHDIR="${FILESDIR}"

# S="${WORKDIR}/dontknow-${PV}/"

NAME="NDepend.Path"
PRJ=${NAME}
FULLSLN=${NAME}.sln

src_prepare() {
	elog "src_prepare"
}

src_compile() {
	exbuild ${FULLSLN}
}

src_install() {
	elog "Installing ${PRJ}.dll into GAC "
	egacinstall ${PRJ}/bin/${PRJ}.dll
}
