# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
SLOT="3"

KEYWORDS="~amd64 ~ppc ~x86"
USE_DOTNET="net45"

inherit msbuild gac mono-pkg-config

NAME="Autofac.Configuration"
HOMEPAGE="https://github.com/Autofac/${NAME}"

EGIT_COMMIT="ce3c12c67600a145ba31a21f3b3be27c4473f2f3"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
RESTRICT="mirror"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/autofac/Autofac.Configuration"
DESCRIPTION="Configuration support for Autofac IoC"
LICENSE="MIT" # https://github.com/autofac/Autofac.Configuration/blob/develop/LICENSE

IUSE="+${USE_DOTNET} +debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-4.0.2.5
	dev-dotnet/autofac:3
	dev-dotnet/aspnet-configuration
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

KEY2="${DISTDIR}/mono.snk"

function output_filename() {
	if use debug; then
		DIR="Debug"
	else
		DIR="Release"
	fi
	echo "bin/${DIR}/Autofac.Configuration.dll"
}

src_prepare() {
	eapply --reverse "${FILESDIR}/Autofac.Configuration.csproj-3.5.2.patch"
	eapply_user
}

src_compile() {
	emsbuild "/p:SignAssembly=true" "/p:PublicSign=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" /p:VersionNumber=${PV} "Autofac.Configuration.csproj"
	sn -R "$(output_filename)" "${KEY2}" || die
}

src_install() {
	egacinstall "$(output_filename)"
	einstall_pc_file "${PN}" "${PV}" "Autofac.Configuration.dll"
}
