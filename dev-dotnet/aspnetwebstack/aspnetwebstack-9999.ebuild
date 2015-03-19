# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit eutils git-2

DESCRIPTION="Mono copy of the Microsoft ASP.NET Web Stack (MVC, Razor etc)"
HOMEPAGE="https://github.com/martinjt/aspnetwebstack"
EGIT_REPO_URI="https://github.com/martinjt/aspnetwebstack.git"
EGIT_HAS_SUBMODULES="true"
EGIT_MASTER="mono_build_changes"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64 ~x86"
#IUSE=""

RDEPEND="dev-lang/mono
	dev-dotnet/xsp
	"
DEPEND="${RDEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext
	x11-misc/shared-mime-info
	x11-terms/xterm
	"
	
S="${WORKDIR}/${PN}-${P}"

src_compile() {
   xbuild  Runtime.sln
}

