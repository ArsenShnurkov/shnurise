# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils mono-utils git-2

DESCRIPTION="ICSharpCode.TextEditor library"
LICENSE="MIT"
HOMEPAGE="https://github.com/ArsenShnurkov/ICSharpCode.TextEditor/"
EGIT_REPO_URI="https://github.com/ArsenShnurkov/ICSharpCode.TextEditor.git"
SRC_URI=""

SLOT="0"
IUSE=""
KEYWORDS="amd64 ppc x86"
DEPEND="|| ( >=dev-lang/mono-3.4.0 <dev-lang/mono-9999 )"
RDEPEND="${DEPEND}"

PATCHDIR="${FILESDIR}"

S="${WORKDIR}/ICSharpCode.TextEditor-ICSharpCode-TextEditor-${PV}/"

src_prepare() {
	elog "Patching"
}

src_compile() {
	exbuild ICSharpCode.TextEditor.sln
}

src_install() {
	elog "Installing library"
	egacinstall Project/bin/ICSharpCode.TextEditor.dll
}
