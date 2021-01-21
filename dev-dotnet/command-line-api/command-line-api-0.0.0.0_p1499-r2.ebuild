# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7" # valid EAPI assignment must occur on or before line: 5

KEYWORDS="amd64"
RESTRICT+=" mirror"

SLOT="0"

GITHUB_ACCOUNT="dotnet"
GITHUB_REPONAME="command-line-api"
REPOSITORY="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}"

HOMEPAGE="https://github.com/dotnet/command-line-api"
DESCRIPTION="Library for building command line applications with extensible middleware pipeline"
LICENSE="MIT" # LICENSE_URL="${REPOSITORY}/blob/master/LICENSE.md

COMMON_DEPEND=">=dev-lang/mono-6
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config"

# dotnet.eclass adds dependency "dev-lang/mono" and allows to use C# compiler
inherit dotnet
# mono-pkg-config allows to install .pc-files for monodevelop
inherit mono-pkg-config


EGIT_COMMIT="0c8d7fea8bf5f3e8eefa1e1040accaf2a1117b2b"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

RESTRICT+=" test"

src_prepare() {
	eapply_user
}


# https://stackoverflow.com/a/21941473/4158543
anycpu_dlls()
{
	declare -a ANYCPU_DLLS
	ANYCPU_DLLS+=("${S}/src/System.CommandLine/bin/Release/System.CommandLine.dll")
	echo ${ANYCPU_DLLS[@]}
}

src_compile() {
	cd "${S}/src/System.CommandLine" || die
	mkdir -p bin/Release || die
	/usr/bin/csc \
		-r:System.dll -r:Microsoft.CSharp.dll -r:System.Core.dll \
		/langversion:8.0 \
		*.cs \
		**/*.cs \
		/t:library /out:bin/Release/System.CommandLine.dll || die
}


src_install() {
	local INSTALL_DIR="$(anycpu_current_assembly_dir)"
	insinto "${INSTALL_DIR}"
	#doins "${S}/src/System.CommandLine/bin/Release/System.CommandLine.dll"

	einfo "=== making .pc file ==="
	einfo "$(anycpu_current_assembly_dir)" $(anycpu_dlls)
	elib "$(anycpu_current_assembly_dir)" $(anycpu_dlls)

	dosym "${INSTALL_DIR}/System.CommandLine.dll" "$(anycpu_current_symlink_dir)/System.CommandLine.dll"
}

