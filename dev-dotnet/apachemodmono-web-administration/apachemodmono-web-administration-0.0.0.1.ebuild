# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
SLOT="0"

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +gac developer debug doc"

inherit gac nupkg

NAME=ApacheModmono.Web.Administration
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"
EGIT_COMMIT="d720185fbb5fe1ef959d608c468ec3027c58164d"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="alternative of Microsoft.Web.Administration for Apache with mod_mono"
LICENSE="Apache-2.0" # https://github.com/ArsenShnurkov/ApacheModmono.Web.Administration/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240
"

ASSEMBLY_VERSION="${PV}"

src_prepare() {
	eapply_user
}

src_compile() {
	exbuild_strong /p:VersionNumber="${ASSEMBLY_VERSION}" "${NAME}.sln"
}

src_install() {
	if use debug; then
		DIR=Debug
	else
		DIR=Release
	fi
	insinto "/usr/lib/mono/${EBUILD_FRAMEWORK}"
	doins "${NAME}/bin/${DIR}/${NAME}.dll"
	if use developer; then
		doins "${NAME}/bin/${DIR}/${NAME}.dll.mdb"
	fi
	einstall_pc_file "${PN}" "${PV}" "${NAME}"
}

pkg_preinst()
{
	egacadd "${D}/usr/lib/mono/${EBUILD_FRAMEWORK}/${NAME}.dll"
	rm "${D}/usr/lib/mono/${EBUILD_FRAMEWORK}/${NAME}.dll" || die
	if use developer; then
		rm "${D}/usr/lib/mono/${EBUILD_FRAMEWORK}/${NAME}.dll.mdb"
	fi
	rmdir "${D}/usr/lib/mono/${EBUILD_FRAMEWORK}" || die
	rmdir "${D}/usr/lib/mono" || die
	rmdir "${D}/usr/lib" || die
	# rmdir "${D}/usr" - it is not empty, contains lib64
}

pkg_prerm()
{
	egacdel "${NAME}"
}
