# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

# ~amd64 means "not stabilised, may not work"
KEYWORDS="amd64"
SLOT="0"

DESCRIPTION="tool to help the programmer output log statements to a variety of output targets"
LICENSE="Apache-2.0"
HOMEPAGE="http://logging.apache.org/log4net/"

BDEPEND=">=dev-lang/mono-4.5"
RDEPEND=">=dev-lang/mono-4.5"
DEPEND="${RDEPEND}"

# $(get_libdir) allows to determine install location of mono runtime and it's disk structures (GAC)
# pkgconfig is also platform-dependent, but allows to use .dll files from MonoDevelop
inherit multilib
inherit mono

IUSE=""

# vcs-snapshot.eclass will strip that first dir level and re-add /${P} , so default S works
# eg instead of unpacking to $WORKDIR/foo-dc8s9ee1/ , it will unpack to $WORKDIR/foo-1.2.3/ as expected
inherit vcs-snapshot

REPO_OWNER=apache
REPO_NAME=logging-log4net
EGIT_COMMIT=dbad144815221ffe4ed85efa73134583253dc75b
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/tarball/${EGIT_COMMIT} -> ${P}.tar.gz
	https://dev.gentoo.org/~pacho/dotnet/log4net.snk"

src_compile() {
	/usr/bin/csc \
		"-define:NET_2_0;NET_4_0;NET_4_5;TRACE" \
		$(find src/log4net -name "*.cs") \
		-t:library \
		-r:/usr/lib64/mono/gac/System.Data/4.0.0.0__b77a5c561934e089/System.Data.dll \
		-r:/usr/lib64/mono/gac/System.Web/4.0.0.0__b03f5f7f11d50a3a/System.Web.dll \
		-keyfile:"${DISTDIR}"/log4net.snk \
		-out:log4net.dll || die
}

src_install() {
	local PV_MAJOR=$(ver_cut 1-2  ${PV})

	egacinstall log4net.dll
	dodir /usr/$(get_libdir)/pkgconfig
	sed -e "s:@VERSION@:${PV}:" \
		-e "s:@LIBDIR@:$(get_libdir):" \
		"${FILESDIR}"/${PN}.pc.in-r1 > "${D}"/usr/$(get_libdir)/pkgconfig/${PN}-${PV}.pc
	dosym ${PN}-${PV}.pc /usr/$(get_libdir)/pkgconfig/${PN}-${PV_MAJOR}.pc
	dosym ${PN}-${PV}.pc /usr/$(get_libdir)/pkgconfig/${PN}.pc

	dodoc README.md STATUS.txt
}
