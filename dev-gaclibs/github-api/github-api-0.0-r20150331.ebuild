# Copyright 1999-2015 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet

DESCRIPTION="C# API for github, based on RestSharp"
LICENSE="MIT"

PROJECTNAME="Git.hub"
HOMEPAGE="https://github.com/gitextensions/${PROJECTNAME}"
EGIT_COMMIT="46304b521bb26414a9f1e998a315cd35039a4837"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"

SLOT="0"
IUSE="debug"
KEYWORDS="~x86 ~amd64 ~ppc"

RDEPEND="
	>=dev-lang/mono-3.0
	"
DEPEND="${RDEPEND}
	"

src_prepare() {
	einfo "preparing"
}

src_configure() {
	einfo "configuring"
}

src_compile() {
	einfo "compiling"
}

src_install() {
	einfo "installing"
}
