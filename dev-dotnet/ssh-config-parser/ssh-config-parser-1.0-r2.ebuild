# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7" # valid EAPI assignment must occur on or before line: 5

KEYWORDS="amd64"
RESTRICT+=" mirror"

SLOT="0"

GITHUB_ACCOUNT="JeremySkinner"
GITHUB_REPONAME="Ssh-Config-Parser"
REPOSITORY="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}"

HOMEPAGE="https://github.com/JeremySkinner/Ssh-Config-Parser"
DESCRIPTION="C#/.NET parser for OpenSSH config files"
LICENSE="MIT" # LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"

COMMON_DEPEND=">=dev-lang/mono-6
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config debug"

# dotnet.eclass adds dependency "dev-lang/mono" and allows to use C# compiler
inherit dotnet
# mono-pkg-config allows to install .pc-files for monodevelop
inherit mono-pkg-config


EGIT_COMMIT="04152ebc42ff81b11497cdbacfeb7ab95e79b37f"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

RESTRICT+=" test"

src_prepare() {
	eapply_user
}

DQUOTE='"'
ASSEMBLY_NAMES=("Ssh.Config.Parser")
ASSEMBLY_FILES=()

src_compile() {
	local PARAMETERS="/target:library"
	PARAMETERS+=" /recurse:${S}/SshConfigParser/*.cs"
	PARAMETERS+=" /langversion:8.0"
	if (use debug); then
		PARAMETERS+=" /debug:full"
	fi
        PARAMETERS+=" /out:${DQUOTE}${WORKDIR}/${ASSEMBLY_NAMES[0]}.dll${DQUOTE}"
	einfo ${PARAMETERS}
	/usr/bin/csc ${PARAMETERS} || die "compilation failed"
}

src_install() {
	local INSTALL_DIR="$(anycpu_current_assembly_dir)"
	insinto "${INSTALL_DIR}"
	for assembly_name in "${ASSEMBLY_NAMES[@]}" ; do
		ASSEMBLY_NAME="${WORKDIR}/${assembly_name}"
		einfo "installing  ${DQUOTE}${ASSEMBLY_NAME}.dll${DQUOTE}"
		doins "${ASSEMBLY_NAME}.dll"
		dosym "${INSTALL_DIR}/${assembly_name}.dll" "$(anycpu_current_symlink_dir)/${assembly_name}.dll"
		ASSEMBLY_FILES+=( "${INSTALL_DIR}/${assembly_name}.dll")
		if (use debug); then
			einfo "installing  ${DQUOTE}${ASSEMBLY_NAME}.pdb${DQUOTE}"
			doins "${ASSEMBLY_NAME}.pdb"
		fi
	done
	einstall_pc_file "${CATEGORY}-${PN}" "${PV}" "${ASSEMBLY_FILES[@]}"
}
