# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7" # valid EAPI assignment must occur on or before line: 5

KEYWORDS="~amd64 ~x86 ~ppc"
RESTRICT+=" mirror test"

SLOT="0"

DESCRIPTION="SSH.NET is a Secure Shell (SSH) library for .NET, optimized for parallelism."
LICENSE="MIT" # LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"
HOMEPAGE="https://github.com/sshnet/SSH.NET"

COMMON_DEPEND="
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config gac debug"

inherit msbuild
# mono-pkg-config allows to install .pc-files for monodevelop
inherit mono-pkg-config
# gac allows to install assemblies into GAC
inherit gac


inherit vcs-snapshot

GITHUB_ACCOUNT="sshnet"
GITHUB_REPONAME="SSH.NET"
EGIT_COMMIT="cefdc203d98cd890815e029bc759bc43ec5a9643"
EGIT_BRANCH="develop"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${P}.tar.gz"
#	https://github.com/mono/mono/raw/master/mcs/class/ecma.pub
#	https://github.com/mono/mono/raw/master/mcs/class/mono.snk

METAFILETOBUILD="./src/Renci.SshNet/Renci.SshNet.csproj"

KEY1="${S}/src/Renci.SshNet.snk"
KEY2="${S}/src/Renci.SshNet.snk"

DQUOTE='"'
ASSEMBLY_NAMES=("Renci.SshNet")
ASSEMBLY_FILES=()

src_compile() {
#	if [[ -z ${TOOLS_VERSION} ]]; then
#		TOOLS_VERSION=4.0
#	fi
#	PARAMETERS=" /tv:${TOOLS_VERSION}"
#	if use developer; then
#		SARGS=/p:DebugSymbols=True
#	else
#		SARGS=/p:DebugSymbols=False
#	fi
	PARAMETERS+=" ${SARGS}"
	PARAMETERS+=" /p:SignAssembly=true"
	PARAMETERS+=" /p:AssemblyOriginatorKeyFile=${KEY1}"
	PARAMETERS+=" /v:detailed"

	for x in ${USE_DOTNET} ; do
		FW_UPPER=${x:3:1}
		FW_LOWER=${x:4:1}
		P_FW_VERSION="/p:TargetFrameworkVersion=v${FW_UPPER}.${FW_LOWER}"
		emsbuild_raw ${PARAMETERS} ${P_FW_VERSION} /p:Configuration=$(usedebug_tostring) /p:OutputPath="${WORKDIR}/net_${FW_UPPER}_${FW_LOWER}_$(usedebug_tostring)" "${METAFILETOBUILD}"
		sn -R ${WORKDIR}/net_${FW_UPPER}_${FW_LOWER}_$(usedebug_tostring)/Renci.SshNet.dll "${KEY2}" || die
	done
}

src_install() {
	for x in ${USE_DOTNET} ; do
		FW_UPPER=${x:3:1}
		FW_LOWER=${x:4:1}

		local INSTALL_DIR="$(anycpu_current_assembly_dir)"
		insinto "${INSTALL_DIR}"

		for assembly_name in "${ASSEMBLY_NAMES[@]}" ; do
			ASSEMBLY_NAME="${WORKDIR}/net_${FW_UPPER}_${FW_LOWER}_$(usedebug_tostring)/${assembly_name}"

			einfo "installing  ${DQUOTE}${assembly_name}.dll${DQUOTE}"
			doins "${ASSEMBLY_NAME}.dll"

			if (use debug); then
				einfo "installing  ${DQUOTE}${ASSEMBLY_NAME}.pdb${DQUOTE}"
				doins "${ASSEMBLY_NAME}.pdb"
			fi

			dosym "${INSTALL_DIR}/${assembly_name}.dll" "$(anycpu_current_symlink_dir)/${assembly_name}.dll"

			egacinstall "${ASSEMBLY_NAME}.dll"

			ASSEMBLY_FILES+=( "${INSTALL_DIR}/${assembly_name}.dll" )
		done
		einstall_pc_file "${CATEGORY}/${PN}" "${PV}" "${ASSEMBLY_FILES[@]}"
	done
}

