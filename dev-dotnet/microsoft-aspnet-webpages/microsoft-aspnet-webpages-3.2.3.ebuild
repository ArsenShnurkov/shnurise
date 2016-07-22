# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

PACKAGE_NAME="Microsoft.AspNet.WebPages"
PACKAGE_VERSION="${PV}"

USE_DOTNET="net45"
IUSE="${USE_DOTNET} +nupkg"

inherit nupkg
# nupkg inherits: dotnet eutils versionator mono-env

# without empty SRC_URI, ebuild digest commend will give the message "ebuild ... does not follow correct package syntax"
# this SRC_URI points to icon file
SRC_URI="http://go.microsoft.com/fwlink/?LinkID=288859 -> ${PACKAGE_NAME}.png"
# this is for overlay-based ebuilds, and should be reworked before moving into main tree
RESTRICT="mirror"

DESCRIPTION="core runtime assemblies shared between ASP.NET MVC and ASP.NET Web Pages"
HOMEPAGE="https://www.nuget.org/packages/Microsoft.AspNet.WebPages/"
KEYWORDS="~amd64 ~x86"
LICENSE="net_library_eula_ENU.htm"
SLOT="0"

CDEPEND=">=dev-dotnet/microsoft-aspnet-razor-3.2.3 <dev-dotnet/microsoft-aspnet-razor-3.3.0
	dev-dotnet/microsoft-web-infrastructure"
DEPEND="${CDEPEND}"
#RDEPEND="${CDEPEND}"

src_unpack() {
	enuget_download_rogue_binary "${PACKAGE_NAME}" "${PACKAGE_VERSION}"
}

src_install() {
	enupkg "${WORKDIR}/${PACKAGE_NAME}.${PACKAGE_VERSION}.nupkg"
}
