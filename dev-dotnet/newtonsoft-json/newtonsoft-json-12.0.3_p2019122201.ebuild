# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

# pkg-config = register in pkg-config database
# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# source = install source files for source-level debugging
USE_DOTNET="net45"
IUSE="${USE_DOTNET} +pkg-config debug developer source"

inherit dotnet mono-pkg-config

HOMEPAGE="https://github.com/JamesNK/Newtonsoft.Json"

EGIT_COMMIT="a31156e90a14038872f54eb60ff0e9676ca4a0d8"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz"
NAME="Newtonsoft.Json"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Json.NET is a popular high-performance JSON framework for .NET"
LICENSE="MIT"
LICENSE_URL="https://raw.github.com/JamesNK/Newtonsoft.Json/master/LICENSE.md"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
"

src_prepare() {
	eapply_user
}

src_compile() {
	:;
}

src_install() {
	#insinto "$(get_nuget_trusted_icons_location)"
	#einstall_pc_file "${PN}" "8.0" "${NAME}"
	:;
}

