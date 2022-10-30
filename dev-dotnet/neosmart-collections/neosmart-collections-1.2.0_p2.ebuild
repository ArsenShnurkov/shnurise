# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# implies "inherit mono-env"
# implies "inherit dotnet-native"
# implies "inherit dotnet"
# implies "inherit msbuild-framework"
# implies "inherit msbuild"
inherit gentoo-net-sdk

HOMEPAGE="https://github.com/neosmart/collections"
DESCRIPTION="Collections in C# language for specific cases"
LICENSE="MIT"
LICENSE_URL="https://github.com/neosmart/collections/blob/master/LICENSE"
SLOT="0"
KEYWORDS="amd64 arm64"

IUSE="${USE_DOTNET} +pkg-config debug developer"

EGIT_COMMIT="53d3cd2a38a4a4dc7ebf1a28c9cadd95291be0de"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${CATEGORY}-${PN}-${PV}.zip"
EGIT_REPONAME="collections"
S="${WORKDIR}/${EGIT_REPONAME}-${EGIT_COMMIT}/Collections"

src_install()
{
	doins.dll ${T}/$(usedebug_tostring)/*.dll
}
