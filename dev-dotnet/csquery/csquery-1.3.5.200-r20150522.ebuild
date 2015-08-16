# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=5
inherit autotools dotnet

NAME="CsQuery"
HOMEPAGE="https://github.com/jamietre/${NAME}"

EGIT_COMMIT="696ac0533a3e665a34cdc4050d1f46e91f5a3356"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT=0

DESCRIPTION="CsQuery is a CSS selector engine and jQuery port for .NET 4 and C#"
LICENSE="MIT" # https://github.com/jamietre/CsQuery/blob/master/LICENSE.txt
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/mono-4.0.2.5"
DEPEND="${RDEPEND}
	sys-apps/sed"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
SLN_FILE="${S}/source/CsQuery.sln"
PROJ_FILE_1="${S}/source/CsQuery/CsQuery.csproj"

src_unpack()
{
	# /usr/portage/distfiles/csquery-1.3.5.200.zip
	# /var/tmp/portage/dev-dotnet/csquery-1.3.5.200-r20150522/work/CsQuery-696ac0533a3e665a34cdc4050d1f46e91f5a3356
	default
}

src_prepare() {
	sed -i '/nuget\.targets/d' "${PROJ_FILE_1}" || die

	einfo "Restoring nuget packages for ${S}/source/CsQuery.sln"
	nuget restore "${S}/source/CsQuery.sln"
}

src_configure() {
	default
}

src_compile() {
	cd "${S}/source/" || die

	einfo "compiling ${S}/source/CsQuery.sln"
	exbuild "${S}/source/CsQuery.sln"

#	sed \
#	-e 's|@prefix@|${pcfiledir}/../..|' \
#	-e 's|@exec_prefix@|${prefix}|' \
#	-e "s|@libdir@|\$\{exec_prefix\}/$(get_libdir)|" \
#	-e "s|@libs@|-r:\$\{libdir\}/mono/Nini/Nini.dll|" \
#	-e "s|@VERSION@|${PV}|" \
#	"${FILESDIR}"/nini.pc.in > "${S}"/nini.pc
}

src_install() {
	# egacinstall Nini.dll Nini

#	pkgconfigdir=/usr/$(get_libdir)/pkgconfig
#	insinto ${pkgconfigdir}
#	newins "${S}"/nini.pc ${P}.pc
#	dosym ${P}.pc ${pkgconfigdir}/${PN}-$(get_version_component_range 1-2).pc
#	dosym ${P}.pc ${pkgconfigdir}/${PN}.pc

#	dodoc "${S}"/../CHANGELOG.txt "${S}"/../README.txt

	default
}
