# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
KEYWORDS="~amd64 ~x86"
RESTRICT+=" mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug +gac"

inherit msbuild gac

HOMEPAGE="https://github.com/sshnet/SSH.NET"
DESCRIPTION="SSH.NET is a Secure Shell (SSH) library for .NET, optimized for parallelism."
LICENSE="MIT"

COMMON_DEPEND="
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

NAME="SSH.NET"
REPO_OWNER="sshnet"
REPOSITORY="https://github.com/${REPO_OWNER}/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"

EGIT_BRANCH="develop"
EGIT_COMMIT="bd01d971790a7c1fa73bad35b79ada90bf69e62d"
EGIT_SHORT_COMMIT=${EGIT_COMMIT:0:7}
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${NAME}/tarball/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
#	https://github.com/mono/mono/raw/master/mcs/class/ecma.pub
#	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
RESTRICT+=" test"
S="${WORKDIR}/${REPO_OWNER}-${NAME}-${EGIT_SHORT_COMMIT}"

METAFILETOBUILD="./src/Renci.SshNet/Renci.SshNet.csproj"

GAC_DLL_NAMES="Renci.SshNet "

KEY1="${S}/src/Renci.SshNet.snk"
KEY2="${S}/src/Renci.SshNet.snk"

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
	for dll_name in ${GAC_DLL_NAMES} ; do
		for x in ${USE_DOTNET} ; do
			FW_UPPER=${x:3:1}
			FW_LOWER=${x:4:1}
			egacinstall "${WORKDIR}/net_${FW_UPPER}_${FW_LOWER}_$(usedebug_tostring)/${dll_name}.dll"
		done
	done
#	einstall_pc_file "${PN}" "0.10" ${GAC_DLL_NAMES}
}
