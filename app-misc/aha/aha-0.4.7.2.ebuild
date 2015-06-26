# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
inherit fdo-mime gnome2-utils versionator eutils

DESCRIPTION="Ansi HTML Adapter"
HOMEPAGE="https://github.com/theZiz/aha
http://ziz.delphigl.com/tool_aha.php"

SRC_URI="https://github.com/theZiz/aha/archive/${PV}.tar.gz"

LICENSE="MPL-1.0 LGPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND="
	"
DEPEND="${RDEPEND}
	"
MAKEOPTS="${MAKEOPTS} -j1" #nowarn
