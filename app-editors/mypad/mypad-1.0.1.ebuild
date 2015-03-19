# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils mono-utils

DESCRIPTION="mypad text editor"
LICENSE="MIT"
HOMEPAGE="https://github.com/ArsenShnurkov/mypad-winforms-texteditor/"
# EGIT_REPO_URI="https://github.com/ArsenShnurkov/mypad-winforms-texteditor.git"
SRC_URI=" \
  https://github.com/ArsenShnurkov/mypad-winforms-texteditor/archive/mypad-${PV}.tar.gz \
  "

SLOT="0"
IUSE="kde gnome gnome3 xfce unity mate"
KEYWORDS="amd64 ppc x86"
DEPEND="|| ( >=dev-lang/mono-3.4.0 <dev-lang/mono-9999 ) 
     dev-dotnet/icsharpcodetexteditor"
RDEPEND="${DEPEND}"

PATCHDIR="${FILESDIR}"

S="${WORKDIR}/mypad-winforms-texteditor-mypad-${PV}/"

src_prepare() {
	elog "Patching"
}

src_compile() {
	exbuild MyPad.sln
}

src_install() {
	elog "Installing executable"
	insinto /usr/lib/mypad/
	make_wrapper mypad "mono /usr/lib/mypad/mypad.exe"
}
