# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="2"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer doc +pkg-config +symlink"

inherit xbuild mono-pkg-config

GITHUB_REPONAME="Autofac"
HOMEPAGE="https://github.com/autofac/Autofac"
DESCRIPTION="An addictive .NET IoC container"
LICENSE="MIT" # https://github.com/autofac/Autofac/blob/develop/LICENSE

EGIT_COMMIT="5ad2d85df4e99d3588589d89874672856ba7b60e"
PV4="$(get_version_component_range 1-4)"
TARBALL_EXT=".tar.gz"
SRC_URI="https://github.com/autofac/${GITHUB_REPONAME}/archive/${EGIT_COMMIT}${TARBALL_EXT} -> ${CATEGORY}-${PN}-${PV4}${TARBALL_EXT}
	"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

function output_filename() {
	echo "Core/Source/Autofac/$(output_relpath)/Autofac.dll"
}

src_prepare() {
	dotnet_pkg_setup
	sed -i '/MSBuildCommunityTasksPath/d' "${S}/default.proj" || die
	exbuild /p:AssemblyVersion=${PV} /t:UpdateVersion "${S}/default.proj"
	eapply_user
}

src_compile() {
	exbuild /p:VersionNumber=${PV} "Core/Source/Autofac/Autofac.csproj"
}

src_install() {
	elib "$(output_filename)"
}
