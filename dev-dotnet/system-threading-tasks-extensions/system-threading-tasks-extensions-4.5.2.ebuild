# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
SLOT="4.5.2"
KEYWORDS="amd64"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit dotnet
inherit mono-pkg-config

HOMEPAGE="https://github.com/dotnet/runtime"
DESCRIPTION="Provides additional types that simplify the work of writing concurrent and asynchronous code"
LICENSE="MIT" # https://github.com/dotnet/runtime/blob/master/LICENSE.TXT
S="${WORKDIR}"

src_compile() {
	:;
}

src_install() {
	einstall_pc_file "System.Threading.Tasks.Extensions" "${SLOT}" "/usr/lib/mono/4.8-api/Facades/System.Runtime.dll"
}
