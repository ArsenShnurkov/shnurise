# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
inherit dotnet

DESCRIPTION="Mono copy of the Microsoft ASP.NET Web Stack (MVC, Razor etc)"
HOMEPAGE="https://github.com/martinjt/aspnetwebstack"
SRC_URI="https://github.com/ArsenShnurkov/aspnetwebstack/archive/${P}.tar.gz"

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

src_configure() {
	./configure
}
