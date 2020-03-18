# Copyright 1999-2012 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} developer debug +pkg-config +symlink"

inherit dotnet

EGIT_COMMIT="080d4131ccb8f202aea543b46e861488e906ac8a"

NAME="DotNetZip.Semverd"
HOMEPAGE="https://github.com/haf/DotNetZip.Semverd"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="create, extract, or update zip files with C# (=DotNetZip+SemVer)"
LICENSE="MS-PL" # https://github.com/haf/DotNetZip.Semverd/blob/master/LICENSE

COMMON_DEPEND="
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

function output_filename ( ) {
	echo "src/Zip Reduced/bin/$(usedebug_tostring)/Ionic.Zip.Reduced.dll"
}

src_prepare() {
	eapply_user
}

src_compile() {
	emsbuild "src/Zip Reduced/Zip Reduced.csproj"
}

src_install() {
	elib "$(output_filename)"
}
