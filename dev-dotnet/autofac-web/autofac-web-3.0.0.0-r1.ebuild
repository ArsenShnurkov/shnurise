# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="amd64 ~x86"
RESTRICT="mirror"

SLOT="3"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +debug developer doc"

inherit msbuild mono-pkg-config

GITHUB_REPONAME="Autofac.Web"
HOMEPAGE="https://github.com/autofac/Autofac.Web"
DESCRIPTION="An addictive .NET IoC container"
LICENSE="MIT"

EGIT_COMMIT="f84b3369693ff9231ed48431b78d0f657ca9a81c"
PV4="$(ver_cut 1-4 ${PV})"
TARBALL_EXT=".tar.gz"
SRC_URI="https://github.com/autofac/${GITHUB_REPONAME}/archive/${EGIT_COMMIT}${TARBALL_EXT} -> ${CATEGORY}-${PN}-${PV}${TARBALL_EXT}
	"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

COMMON_DEPEND=""
DEPEND="${COMMON_DEPEND}
	dev-dotnet/autofac:2
"
RDEPEND="${COMMON_DEPEND}
"

function output_filename() {
	echo "$(output_relpath)/Autofac.Integration.Web.dll"
}

src_prepare() {
	sed -i "/SharedKey/d" "Autofac.Integration.Web.csproj" || die
	sed -i "/Sign/d" "Autofac.Integration.Web.csproj" || die
	sed -i "/ProductAssemblyInfo/,+2d" "Autofac.Integration.Web.csproj" || die
	sed -i "/GlobalAssemblyInfo/,+2d" "Autofac.Integration.Web.csproj" || die
	eapply_user
}

src_compile() {
	emsbuild "Autofac.Integration.Web.csproj"
}

src_install() {
	elib "$(output_filename)"
}
