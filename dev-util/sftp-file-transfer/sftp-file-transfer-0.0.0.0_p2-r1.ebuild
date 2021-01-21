# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7" # valid EAPI assignment must occur on or before line: 5

KEYWORDS="amd64"
RESTRICT+=" mirror"

SLOT="0"

GITHUB_ACCOUNT="ArsenShnurkov"
GITHUB_REPONAME="sftp-file-transfer"
REPOSITORY="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}"

HOMEPAGE="https://github.com/ArsenShnurkov/sftp-file-transfer"
DESCRIPTION="C# command line utility for uploading files to sftp"
LICENSE="GPL-3" # LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"

COMMON_DEPEND=">=dev-lang/mono-6
	dev-dotnet/command-line-api
	dev-dotnet/ssh-config-parser
	dev-dotnet/ssh-net
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config debug"

# dotnet.eclass adds dependency "dev-lang/mono" and allows to use C# compiler
inherit dotnet

EGIT_COMMIT="ec82dd2374a0d731b4c4ae29fee2476135ea4f00"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

RESTRICT+=" test"

ASSEMBLY_NAMES=("sftp-file-transfer")

REFERENCES=(
	"System.CommandLine"
	"Ssh.Config.Parser"
	"Renci.SshNet"
)

src_prepare() {
	einfo "Applying user patches"
	eapply_user
}

prepend_ouput_dir()
{
	echo "${WORKDIR}/$(usedebug_tostring)/${1}"
}

# @FUNCTION: prepare_output_dir
# @DESCRIPTION: creates symlinks for all referenced assemblies (and their dependencies)
# $1 = directory to place symlinks into
prepare_output_dir()
{
	einfo "Creating assemblies symlinks directory"
	mkdir  -p "${1}" || die
	einfo "Creating symlinks in \"${1}\""
	ln -s --target-directory="${1}" "$(anycpu_symlink_dir command-line-api 0)/"*.dll || die
	ln -s --target-directory="${1}" "$(anycpu_symlink_dir ssh-config-parser 0)/"*.dll || die
	ln -s --target-directory="${1}" "$(anycpu_symlink_dir ssh-net 0)/"*.dll || die
}

src_compile() {
	REFERENCES_DIR="$(prepend_ouput_dir bin)"

	declare -a LIBS
	for assembly_name in "${REFERENCES[@]}" ; do
		LIBS+=("-r:${REFERENCES_DIR}/${assembly_name}.dll")
	done

	prepare_output_dir "${REFERENCES_DIR}"
	einfo "Perform main compilation"
	declare -a PARAMETERS
	PARAMETERS+=("/langversion:8.0")
	PARAMETERS+=("/recurse:${S}/transfer/*.cs")
	PARAMETERS+=("${LIBS[@]}")
	PARAMETERS+=("/target:exe")
	if (use debug); then
		PARAMETERS+=(" /debug:full")
	fi
	local assembly_name="${ASSEMBLY_NAMES[0]}"
        PARAMETERS+=("/out:$(prepend_ouput_dir ${assembly_name}.exe)")
	einfo /usr/bin/csc "${PARAMETERS[@]}"
	/usr/bin/csc "${PARAMETERS[@]}"|| die "compilation failed"
}

src_install() {
	local INSTALL_DIR="$(executable_assembly_dir)"

	einfo "Installing referenced libraries"
	REFERENCES_DIR="$(prepend_ouput_dir bin)"
	insinto "${INSTALL_DIR}"
	doins "${REFERENCES_DIR}"/*.dll

	einfo "Installing application files"
	insinto "${INSTALL_DIR}"
	for assembly_name in "${ASSEMBLY_NAMES[@]}" ; do
		ASSEMBLY_NAME="$(prepend_ouput_dir ${assembly_name} )"
		einfo "installing  ${DQUOTE}${ASSEMBLY_NAME}.exe${DQUOTE}"
		doins "${ASSEMBLY_NAME}.exe"
		if (use debug); then
			einfo "installing  ${DQUOTE}${ASSEMBLY_NAME}.pdb${DQUOTE}"
			doins "${ASSEMBLY_NAME}.pdb"
		fi
	done

	local assembly_name="${ASSEMBLY_NAMES[0]}"
	local wrapper_name="sftp-file-transfer"
	einfo "Creating wrapper"
	if use debug; then
		make_wrapper "${wrapper_name}" "/usr/bin/mono --debug \"${INSTALL_DIR}/${assembly_name}.exe\""
	else
		make_wrapper "${wrapper_name}" "/usr/bin/mono \"${INSTALL_DIR}/${assembly_name}.exe\""
	fi	
}

