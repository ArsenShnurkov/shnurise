# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="0"
KEYWORDS="amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit dotnet
inherit mono-pkg-config

HOMEPAGE="https://github.com/dotnet/runtime"
DESCRIPTION="low-level functionality for manipulating pointers"
LICENSE="MIT" // https://github.com/dotnet/runtime/blob/master/LICENSE.TXT
S="${WORKDIR}"

src_compile() {
	:;
}

src_install() {
	einstall_pc_file "System.Runtime.CompilerServices.Unsafe" "4.5" "/usr/lib/mono/4.5/System.Runtime.CompilerServices.Unsafe.dll"
}
