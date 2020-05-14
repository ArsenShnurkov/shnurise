# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
RESTRICT="mirror"
KEYWORDS="amd64"

SLOT="$(ver_cut 1-2)"

SLOT_OF_API="${SLOT}" # slot for ebuild with API of msbuild
VER="${SLOT_OF_API}.0.0" # version of resulting .dll files in GAC

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} +gac +mskey debug developer"

# msbuild-framework.eclass is inherited to get the access to the locations 
# $(MSBuildBinPath) and $(MSBuildSdksPath)
inherit msbuild-framework xbuild gac

GITHUB_ACCOUNT="Microsoft"
GITHUB_PROJECTNAME="msbuild"
EGIT_COMMIT="88f5fadfbef809b7ed2689f72319b7d91792460e"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz
	mskey? ( https://github.com/Microsoft/msbuild/raw/master/src/MSFT.snk )
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
	"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/Microsoft/msbuild"
DESCRIPTION="default tasks for Microsoft Build Engine (MSBuild)"
LICENSE="MIT" # https://github.com/Microsoft/msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
	dev-dotnet/msbuild-tasks-api:${SLOT_OF_API}[pkg-config] developer? ( dev-dotnet/msbuild-tasks-api:${SLOT_OF_API}[pkg-config,developer] )
	dev-dotnet/system-collections-immutable[pkg-config] developer? ( dev-dotnet/system-collections-immutable[pkg-config,developer] )
	dev-dotnet/system-reflection-metadata[pkg-config] developer? ( dev-dotnet/system-reflection-metadata[pkg-config,developer] )
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/buildtools
	>=dev-dotnet/msbuildtasks-1.5.0.240-r1
"

PROJ0=Microsoft.Build.Tasks
PROJ0_DIR=src/Tasks

METAFILE_FO_BUILD="${S}/${PROJ0_DIR}/${PROJ0}.csproj"

function output_filename ( ) {
	echo "${S}/${PROJ0_DIR}/bin/$(usedebug_tostring)/${PROJ0}.Core.dll"
}

src_prepare() {
	cp "${FILESDIR}/${SLOT}/xbuild-${PROJ0}.csproj" "${S}/${PROJ0_DIR}/${PROJ0}.csproj" || die
	eapply_user
}

src_compile() {
	if use developer; then
		SARGS=/p:DebugSymbols=True
	else
		SARGS=/p:DebugSymbols=False
	fi

	if use debug; then
		if use developer; then
			SARGS=${SARGS} /p:DebugType=full
		fi
	else
		if use developer; then
			SARGS=${SARGS} /p:DebugType=pdbonly
		fi
	fi

	exbuild_raw /v:detailed  /p:MonoBuild=true /p:MachineIndependentBuild=true /p:TargetFrameworkVersion=v4.6 "/p:Configuration=$(usedebug_tostring)" ${SARGS} "/p:PublicKeyToken=$(token)" "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:DelaySign=true" "/p:AssemblyOriginatorKeyFile=$(token_key)" "${METAFILE_FO_BUILD}"
	sn -R "$(output_filename)" "$(signing_key)" || die
}

src_install() {
	egacinstall "$(output_filename)"

#	insinto "$(MSBuildBinPath)"
	insinto "/usr/share/msbuild/$(ver_cut 1 ${SLOT}).0/bin"
	doins "$(output_filename)"
	doins "${FILESDIR}/${SLOT}/Microsoft.Common.tasks"
}

