# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils dotnet

DESCRIPTION="mypad text editor written with C# and System Windows Forms (SWF, WinForms)"
LICENSE="MIT"

HOMEPAGE="https://github.com/ArsenShnurkov/mypad-winforms-texteditor/"
EGIT_REPO_URI="https://github.com/ArsenShnurkov/mypad-winforms-texteditor.git"
SRC_URI=""

SLOT="0"

# IUSE="kde gnome gnome3 xfce unity mate"
IUSE="debug"

KEYWORDS="~amd64 ~ppc ~x86"
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
