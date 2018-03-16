# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} developer debug +pkg-config +symlink"

inherit msbuild mono-pkg-config

SRC_URI="https://github.com/haf/DotNetZip.Semverd/archive/v1.9.3.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	"

S="${WORKDIR}/DotNetZip.Semverd-${PV}"

HOMEPAGE="https://github.com/haf/DotNetZip.Semverd"
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
	eapply "${FILESDIR}/version-${PV}.patch"
	eapply_user
}

src_compile() {
	emsbuild "src/Zip Reduced/Zip Reduced.csproj"
}

src_install() {
	elib "$(output_filename)"
}
