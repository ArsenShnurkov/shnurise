# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
SLOT="0"
RESTRICT="mirror"

KEYWORDS="amd64"
USE_DOTNET="net45"

inherit vcs-snapshot
inherit gentoo-net-sdk
inherit msbuild
inherit wrapper

IUSE="+${USE_DOTNET} debug developer"

NAME="gplex"
HOMEPAGE="https://github.com/k-john-gough/${NAME}"
DESCRIPTION="C# version of lex (Garden Point Lex)"
LICENSE="BSD" # https://github.com/k-john-gough/gplex/blob/master/LICENSE.md

GITHUB="https://github.com/k-john-gough/${NAME}"
EGIT_COMMIT="8e9c91b39e7483c2fa937b8af5889d9e78ba4cf7"
SRC_URI="${GITHUB}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${CATEGORY}-${PN}-${PV}"

src_compile() {
	emsbuild "GPLEXv1.csproj"
}

src_install() {
	insinto "/usr/share/${PN}"
	if use debug; then
		newins bin/Debug/Gplex.exe gplex.exe
		make_wrapper gplex "/usr/bin/mono --debug /usr/share/${PN}/gplex.exe"
	else
		newins bin/Release/Gplex.exe gplex.exe
		make_wrapper gplex "/usr/bin/mono /usr/share/${PN}/gplex.exe"
	fi
}
