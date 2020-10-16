# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# for calling eautoreconf, which creates "autoconf" file from "autoconf.ac"
inherit autotools

inherit eutils

# for function "dotnet_multilib_comply" which is called in src_install
inherit dotnet-native

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.mono-project.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~arm ~arm64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x86-linux ~x86-solaris"

# SRC_URI="http://download.mono-project.com/sources/${PN}/${P}.tar.gz"
REPO_OWNER=mono
REPO_NAME=libgdiplus
EGIT_COMMIT=9efff6a9ed1c3286362270b704dcdcf7a2670d54
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/tarball/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/mono-libgdiplus-9efff6a"

IUSE="cairo -test"

#skip tests due https://bugs.gentoo.org/687784
RESTRICT="test"

RDEPEND=">=dev-libs/glib-2.2.3:2
	>=media-libs/freetype-2.3.7
	>=media-libs/fontconfig-2.6
	>=media-libs/libpng-1.4:0
	x11-libs/libXrender
	x11-libs/libX11
	x11-libs/libXt
	>=x11-libs/cairo-1.8.4[X]
	media-libs/libexif
	>=media-libs/giflib-5.1.2
	virtual/jpeg:0
	media-libs/tiff:0
	!cairo? ( >=x11-libs/pango-1.20 )
	test? ( >=dev-cpp/gtest-1.10.0 )
	"
DEPEND="${RDEPEND}"

src_prepare() {
	default
	if ! use test; then
		eapply "${FILESDIR}/remove-tests-${PV}.patch"
	fi
	eautoreconf
#	eapply "${FILESDIR}/${PN}-${PV}-cofigure.patch"
#	touch external/googletest/README.md || die
}

src_configure() {
	econf \
		--disable-dependency-tracking \
		--disable-static \
		$(usex cairo "" "--with-pango")
}

src_install () {
	default

	dotnet_multilib_comply
	local commondoc=( AUTHORS ChangeLog README TODO )
	for docfile in "${commondoc[@]}"; do
		[[ -e "${docfile}" ]] && dodoc "${docfile}"
	done
	[[ "${DOCS[@]}" ]] && dodoc "${DOCS[@]}"

	# see
	# https://mgorny.pl/articles/the-ultimate-guide-to-eapi-7.html#related-eclass-changes
	#prune_libtool_files
	find "${D}" -name '*.la' -delete || die
}
