# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="4.5.0"
KEYWORDS="amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit dotnet
inherit mono-pkg-config

HOMEPAGE="https://github.com/dotnet/runtime"
DESCRIPTION="Provides the System.ValueTuple structs, which implement the underlying types for tuples in C#"
LICENSE="MIT" # https://github.com/dotnet/runtime/blob/master/LICENSE.TXT
S="${WORKDIR}"

src_compile() {
	:;
}

src_install() {
	einstall_pc_file "System.ValueTuple" "${SLOT}" "/usr/lib/mono/4.8-api/Facades/System.Runtime.dll"
}
