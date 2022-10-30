# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# implies "inherit mono-env"
# implies "inherit dotnet-native"
# implies "inherit dotnet"
# implies "inherit msbuild-framework"
# implies "inherit msbuild"
inherit gentoo-net-sdk

HOMEPAGE="https://github.com/neosmart/unicode.net"
DESCRIPTION="A Unicode library for .NET, supporting UTF8, UTF16, and UTF32, with emoji"
LICENSE="MIT"
LICENSE_URL="https://github.com/neosmart/unicode-net/blob/master/LICENSE"
SLOT="0"
KEYWORDS="amd64 arm64"

IUSE="${USE_DOTNET} +pkg-config debug developer"

EGIT_COMMIT="15ca8e5ee372ecf15aa60f2382d7481e53ae28ae"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${CATEGORY}-${PN}-${PV}.zip"
EGIT_REPONAME="unicode.net"
S="${WORKDIR}/${EGIT_REPONAME}-${EGIT_COMMIT}/unicode"

DEPEND="dev-dotnet/neosmart-collections"

src_install()
{
	PC_NAME=Unicode.Net
	PC_VERSION=$( ver_cut 1-2 "${PV}" )
	doins.dll ${T}/$(usedebug_tostring)/*.dll
}
