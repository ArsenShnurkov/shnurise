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
EGIT_COMMIT="ec3b0344e3b25692a9d396e6868d781a44f06275"
PV4="$(get_version_component_range 1-4)"
TARBALL_EXT=".tar.gz"
SRC_URI="https://github.com/nuget/${GITHUB_REPONAME}/archive/${EGIT_COMMIT}${TARBALL_EXT} -> ${CATEGORY}-${PN}-${PV4}${TARBALL_EXT}
	"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

LICENSE="Apache-2.0"

src_compile() {
	emsbuild "src/Core/Core.csproj"
}

src_install() {
	elib "src/Core/bin/$(usedebug_tostring)/NuGet.Core.dll"
}
