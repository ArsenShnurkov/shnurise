# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~x86"
RESTRICT+=" mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config +symlink debug developer"

inherit xbuild mono-pkg-config gac nupkg

HOMEPAGE="http://cecil.pe/"
DESCRIPTION="System.Reflection alternative to generate and inspect .NET executables/libraries"
LICENSE="MIT"

COMMON_DEPEND="
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

NAME="cecil"
REPO_OWNER="jbevain"
REPOSITORY="https://github.com/${REPO_OWNER}/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"
ICONMETA="http://www.iconeasy.com/icon/ico/Movie%20%26%20TV/Looney%20Tunes/Cecil%20Turtle%20no%20shell.ico"
ICON_URL="file://${FILESDIR}/cecil_turtle_no_shell.png"

EGIT_BRANCH="master"
EGIT_COMMIT="848c4d5b87f92e3fecd6e48c12270cd138536a83"
EGIT_SHORT_COMMIT=${EGIT_COMMIT:0:7}
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${NAME}/tarball/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
#	https://github.com/mono/mono/raw/master/mcs/class/ecma.pub
#	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
RESTRICT+=" test"
# jbevain-cecil-045b0f9
S="${WORKDIR}/${REPO_OWNER}-${NAME}-${EGIT_SHORT_COMMIT}"

METAFILETOBUILD="./Mono.Cecil.sln"

GAC_DLL_NAMES="Mono.Cecil Mono.Cecil.Mdb Mono.Cecil.Pdb Mono.Cecil.Rocks"

NUSPEC_ID="Mono.Cecil"
NUSPEC_FILE="${S}/Mono.Cecil.nuspec"
NUSPEC_VERSION="0.10.0.2016111002"

#KEY1="${DISTDIR}/ecma.pub"
#KEY2="${DISTDIR}/mono.snk"
KEY1="${S}/cecil.snk"
KEY2="${S}/cecil.snk"

src_prepare() {
#	enuget_restore "${METAFILETOBUILD}"

#	eapply "${FILESDIR}/nuspec-${PV}.patch"
#	eapply "${FILESDIR}/sln-${PV}.patch"
	sed -i "s?net_4_0?net_4_5?g" "${METAFILETOBUILD}" || die
	#eapply "${FILESDIR}/csproj-${PV}.patch"

	eapply_user
}

src_configure() {
	:;
}

src_compile() {
	if [[ -z ${TOOLS_VERSION} ]]; then
		TOOLS_VERSION=4.0
	fi
	PARAMETERS=" /tv:${TOOLS_VERSION}"
	if use developer; then
		SARGS=/p:DebugSymbols=True
	else
		SARGS=/p:DebugSymbols=False
	fi
	PARAMETERS+=" ${SARGS}"
	PARAMETERS+=" /p:SignAssembly=true"
	PARAMETERS+=" /p:AssemblyOriginatorKeyFile=${KEY1}"
	PARAMETERS+=" /v:detailed"

	for x in ${USE_DOTNET} ; do
		FW_UPPER=${x:3:1}
		FW_LOWER=${x:4:1}
		P_FW_VERSION="/p:TargetFrameworkVersion=v${FW_UPPER}.${FW_LOWER}"
		local CONFIGURATION="net_${FW_UPPER}_${FW_LOWER}_$(usedebug_tostring)"
		einfo "Building configuration '${CONFIGURATION}'"
		P_CONFIGURATION="/p:Configuration=${CONFIGURATION}"
		exbuild_raw ${PARAMETERS} ${P_FW_VERSION} ${P_CONFIGURATION} "${METAFILETOBUILD}"

		# https://github.com/gentoo/dotnet/issues/305
		sn -R ${S}/bin/${CONFIGURATION}/Mono.Cecil.dll "${KEY2}" || die
		sn -R ${S}/bin/${CONFIGURATION}/Mono.Cecil.Mdb.dll "${KEY2}" || die
		sn -R ${S}/bin/${CONFIGURATION}/Mono.Cecil.Pdb.dll "${KEY2}" || die
		sn -R ${S}/bin/${CONFIGURATION}/Mono.Cecil.Rocks.dll "${KEY2}" || die
	done

	# run nuget_pack
	enuspec -Prop "id=${NUSPEC_ID};version=${NUSPEC_VERSION}" ${NUSPEC_FILE}
}

src_install() {
	for dll_name in ${GAC_DLL_NAMES} ; do
		for x in ${USE_DOTNET} ; do
			FW_UPPER=${x:3:1}
			FW_LOWER=${x:4:1}
			egacinstall "bin/net_${FW_UPPER}_${FW_LOWER}_$(usedebug_tostring)/${dll_name}.dll"
		done
	done
	einstall_pc_file "${PN}" "0.10" ${GAC_DLL_NAMES}

	enupkg "${WORKDIR}/${NUSPEC_ID}.${NUSPEC_VERSION}.nupkg"
}
