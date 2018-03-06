# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~x86 ~amd64"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer +pkg-config +symlink"

inherit eutils
inherit msbuild mono-pkg-config

DESCRIPTION="Nuget - .NET Package Manager"
HOMEPAGE="http://nuget.codeplex.com"
GITHUB_REPONAME=NuGet2
EGIT_COMMIT="239f46b8f5ca6763021a931f136a2db375a8e807"
PV4="$(get_version_component_range 1-4)"
TARBALL_EXT=".tar.gz"
SRC_URI="https://github.com/nuget/${GITHUB_REPONAME}/archive/${EGIT_COMMIT}${TARBALL_EXT} -> ${CATEGORY}-${PN}-${PV4}${TARBALL_EXT}
	"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

LICENSE="Apache-2.0"

CDEPEND=""
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

# note about blocking nuget:
# there are at least two versions of it - on from mono, one from mrward
# see https://bugzilla.xamarin.com/show_bug.cgi?id=27693
# i think version from mrward is enough for now, 
# that is why there is no slotted install or two different names/locations

pkg_setup() {
	dotnet_pkg_setup
	mozroots --import --sync --machine
}

src_configure() {
	export EnableNuGetPackageRestore="true"
}

src_compile() {
	emsbuild "src/Core/Core.csproj"
}

src_install() {
	elib "src/Core/bin/$(usedebug_tostring)/NuGet.Core.dll"
}
