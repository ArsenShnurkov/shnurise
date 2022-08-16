# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8" # valid EAPI assignment must occur on or before line: 5

KEYWORDS="amd64 arm64"
RESTRICT+=" mirror"

# No need to specify slot, because there are no incompatible versions known
#SLOT="1.9.71.2"
SLOT="0"

GITHUB_ACCOUNT="commandlineparser"
GITHUB_REPONAME="commandline"
REPOSITORY="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}"

HOMEPAGE="https://github.com/commandlineparser/commandline"
DESCRIPTION="C# (and F#) command line parser with standardized *nix getopt style"
LICENSE="MIT"

COMMON_DEPEND=">=dev-lang/mono-6
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config debug developer"

inherit msbuild # allows to build .csproj files
inherit mono-pkg-config # mono-pkg-config allows to install .pc-files for monodevelop

EGIT_COMMIT="205094c0c135ab5b6816f3eb0e6a84ddced5b0e2"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

RESTRICT+=" test"

src_prepare() {
	eapply "${FILESDIR}/remove-signing.patch"
	eapply_user
}

src_compile() {
	emsbuild src/libcmdline/CommandLine.csproj
}

function bin_dir ( ) {
	echo "bin/$(usedebug_tostring)"
}

ASSEMBLY_NAME=CommandLine

function output_filename ( ) {
	echo "${S}/src/libcmdline/$(bin_dir)/${ASSEMBLY_NAME}.dll"
}

src_install() {
	local INSTALL_DIR="$(anycpu_current_assembly_dir)"
	einfo "\${INSTALL_DIR}=${INSTALL_DIR}"

	insinto "${INSTALL_DIR}"
	elib "${INSTALL_DIR}" "$(output_filename)" 
	# elib also calls einstall_pc_file
	#  But this is an alias with another name
	einstall_pc_file "CommandLineParser" "1.9.71" /usr/share/mono/assemblies/${PN}${APPENDIX}/${ASSEMBLY_NAME}.dll

	dosym "${INSTALL_DIR}/${ASSEMBLY_NAME}.dll" "$(anycpu_current_symlink_dir)/${ASSEMBLY_NAME}.dll"
}
