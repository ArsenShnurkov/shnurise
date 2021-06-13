# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# for calling eautoreconf, which creates "autoconf" file from "autoconf.ac"
inherit autotools

# https://devmanual.gentoo.org/eclass-reference/vcs-snapshot.eclass/index.html
# for setting ${S} variable
inherit vcs-snapshot

inherit eutils

inherit multilib-minimal

DESCRIPTION="Library for using System.Drawing with mono"
HOMEPAGE="http://www.mono-project.com"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64"

# SRC_URI="http://download.mono-project.com/sources/${PN}/${P}.tar.gz"
REPO_OWNER=mono
REPO_NAME=libgdiplus
EGIT_COMMIT=7d12c7d1e42669d3d92999094335ec30998e5976
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/tarball/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
# dev-dotnet-libgdiplus-6.0.5_p75
S="${WORKDIR}/${CATEGORY}-${PN}-${PV}"

IUSE="+cairo -test"

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

	# https://devmanual.gentoo.org/eclass-reference/autotools.eclass/index.html
	eautoreconf
	# https://linux.die.net/man/1/autoreconf
	# you can make 'autoreconf' remake all of the files by giving it the '--force' option.
}

multilib_src_configure() {
	LC_ALL="C" ECONF_SOURCE="${S}" \
	econf \
		--disable-dependency-tracking \
		--disable-static \
		$(usex cairo "" "--with-pango")
}

multilib_src_install () {
	default

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
