# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet

SLOT="3"
DESCRIPTION="C# API for github, based on RestSharp"
LICENSE="MIT"
HOMEPAGE="https://github.com/gitextensions/Git.hub"
KEYWORDS="~amd64 ~x86"
SRC_URI="https://github.com/ArsenShnurkov/Git.hub/archive/2013.11.15.tar.gz -> git-hub-gitext-0.0-p20131115.tar.gz"
IUSE="debug"

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
