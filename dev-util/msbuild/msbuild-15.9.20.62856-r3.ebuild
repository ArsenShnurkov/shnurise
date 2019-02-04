# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
RESTRICT="mirror"
KEYWORDS="~amd64 ~x86 ~ppc"

# see docs:
# https://github.com/gentoo/gentoo/commit/59a1a0dda7300177a263eb1de347da493f09fdee
# https://devmanual.gentoo.org/eclass-reference/eapi7-ver.eclass/index.html
inherit eapi7-ver 
SLOT="$(ver_cut 1-2)"

SLOT_OF_API="${SLOT}" # slot for ebuild with API of msbuild
VER="${PV}" # version of resulting msbuild.exe

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} +gac mskey developer debug +roslyn symlink"

inherit xbuild gac

# msbuild-framework.eclass is inherited to get the access to the locations 
# $(MSBuildBinPath) and $(MSBuildSdksPath)
inherit msbuild-framework

GITHUB_ACCOUNT="Microsoft"
GITHUB_PROJECTNAME="msbuild"
EGIT_COMMIT="88f5fadfbef809b7ed2689f72319b7d91792460e"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz
	mskey? ( https://github.com/Microsoft/msbuild/raw/master/src/MSFT.snk )
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
	"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/Microsoft/msbuild"
DESCRIPTION="Microsoft Build Engine (MSBuild) is an XML-based platform for building applications"
LICENSE="MIT" # https://github.com/Microsoft/msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
	dev-dotnet/msbuild-tasks-api:${SLOT_OF_API} developer? ( dev-dotnet/msbuild-tasks-api:${SLOT_OF_API}[developer] )
	dev-dotnet/msbuild-defaulttasks:${SLOT_OF_API} developer? ( dev-dotnet/msbuild-defaulttasks:${SLOT_OF_API}[developer] )
	roslyn? ( dev-dotnet/msbuild-roslyn-csc )
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/buildtools
	>=dev-dotnet/msbuildtasks-1.5.0.240-r1
"

PROJ1=Microsoft.Build
PROJ1_DIR=src/Build
PROJ2=MSBuild
PROJ2_DIR=src/MSBuild

src_prepare() {
	cp "${FILESDIR}/${PV}/mono-${PROJ1}.csproj" "${S}/${PROJ1_DIR}" || die
	cp "${FILESDIR}/${PV}/mono-${PROJ2}.csproj" "${S}/${PROJ2_DIR}" || die
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

	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=$(usedebug_tostring)" ${SARGS} "/p:VersionNumber=${VER}" "/p:ReferencesVersion=${SLOT_OF_API}.0.0" "/p:PublicKeyToken=$(token)" "/p:RootPath=${S}" "/p:MonoBuild=true" "/p:SignAssembly=true" "/p:DelaySign=true" "/p:AssemblyOriginatorKeyFile=$(token_key)" "${S}/${PROJ2_DIR}/mono-${PROJ2}.csproj"
	sn -R "${PROJ1_DIR}/bin/$(usedebug_tostring)/${PROJ1}.dll" "$(signing_key)" || die
}

src_install() {
	egacinstall "${PROJ1_DIR}/bin/$(usedebug_tostring)/${PROJ1}.dll"

	TargetVersion=${SLOT}
	insinto "$(MSBuildBinPath)"
	newins "${PROJ2_DIR}/bin/$(usedebug_tostring)/${PROJ2}.exe" MSBuild.exe
	doins "${S}/src/Tasks/Microsoft.Common.props"
	doins "${S}/src/Tasks/Microsoft.Common.targets"
	doins "${S}/src/Tasks/Microsoft.Common.overridetasks"
	doins "${S}/src/Tasks/Microsoft.CSharp.targets"
	doins "${S}/src/Tasks/Microsoft.CSharp.CurrentVersion.targets"
	doins "${S}/src/Tasks/Microsoft.Common.CurrentVersion.targets"
	doins "${S}/src/Tasks/Microsoft.NETFramework.props"
	doins "${S}/src/Tasks/Microsoft.NETFramework.CurrentVersion.props"
	doins "${S}/src/Tasks/Microsoft.NETFramework.targets"
	doins "${S}/src/Tasks/Microsoft.NETFramework.CurrentVersion.targets"
	keepdir "$(MSBuildSdksPath)"

	if use debug; then
		make_wrapper msbuild-${SLOT} "/usr/bin/mono --debug $(MSBuildBinPath)/MSBuild.exe"
	else
		make_wrapper msbuild-${SLOT} "/usr/bin/mono $(MSBuildBinPath)/MSBuild.exe"
	fi

	if use symlink; then
		dosym ${EPREFIX}/usr/bin/msbuild-${SLOT} /usr/bin/msbuild || die
	fi
}

pkg_postinst() {
	if ! has "msbuild${SLOT/./-}" ${MSBUILD_TARGETS}; then
		   elog "To install Sdks for this version of msbuild, you will need to"
		   elog "add msbuild${SLOT/./-} to your MSBUILD_TARGETS USE_EXPAND variable."
		   elog
	fi
}
