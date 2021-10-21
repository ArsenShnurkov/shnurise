# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="amd64 ~arm64"
SLOT="0"
RESTRICT="mirror"

USE_DOTNET="net45"

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="${USE_DOTNET} debug developer +gac pkg-config nupkg test"

inherit mono-pkg-config
inherit msbuild
inherit gentoo-net-sdk

NAME="Newtonsoft.Json"
HOMEPAGE="https://github.com/JamesNK/Newtonsoft.Json"

EGIT_COMMIT="b529abba7c71ee165ff5b60debf0ecbc7a3efcc1"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Json.NET is a popular high-performance JSON framework for .NET"
LICENSE="MIT"
LICENSE_URL="https://raw.github.com/JamesNK/Newtonsoft.Json/master/LICENSE.md"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
"

final_dll() {
#	echo "${S}/Src/Newtonsoft.Json/bin/$(usedebug_tostring)/Net45/Newtonsoft.Json.dll"
	echo "${S}/Src/Newtonsoft.Json/bin/$(usedebug_tostring)/Newtonsoft.Json.dll"
}

src_prepare() {
	eapply "${FILESDIR}/system-numerics.patch"
	gentoo-net-sdk_src_prepare
}

src_compile() {
	local METAFILETOBUILD=Src/Newtonsoft.Json/Newtonsoft.Json.csproj

	emsbuild "${METAFILETOBUILD}"
}

src_install() {
	elib  "$(anycpu_current_assembly_dir)" "$(final_dll)"
}
