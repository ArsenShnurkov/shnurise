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
IUSE="+${USE_DOTNET} +gac developer debug doc +roslyn symlink"

inherit xbuild gac

# msbuild-locations.eclass is inherited to get the access to the locations 
# $(MSBuildBinPath) and $(MSBuildSdksPath)
inherit msbuild-locations

GITHUB_ACCOUNT="Microsoft"
GITHUB_PROJECTNAME="msbuild"
EGIT_COMMIT="51c3830b82db41a313305d8ee5eb3e8860a5ceb5"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
	"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/Microsoft/msbuild"
DESCRIPTION="Microsoft Build Engine (MSBuild) is an XML-based platform for building applications"
LICENSE="MIT" # https://github.com/mono/linux-packaging-msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
	dev-dotnet/msbuild-tasks-api:${SLOT_OF_API} developer? ( dev-dotnet/msbuild-tasks-api[developer] )
	dev-dotnet/msbuild-defaulttasks developer? ( dev-dotnet/msbuild-defaulttasks[developer] )
	roslyn? ( dev-dotnet/msbuild-roslyn-csc )
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/buildtools
	>=dev-dotnet/msbuildtasks-1.5.0.240-r1
"

KEY2="${DISTDIR}/mono.snk"

PROJ1=Microsoft.Build
PROJ1_DIR=src/Build
PROJ2=MSBuild
PROJ2_DIR=src/MSBuild

src_prepare() {
	eapply "${FILESDIR}/${PV}/dir.props.diff"
	eapply "${FILESDIR}/${PV}/dir.targets.diff"
	eapply "${FILESDIR}/${PV}/src-dir.targets.diff"
	eapply "${FILESDIR}/${PV}/tasks.patch"
	eapply "${FILESDIR}/${PV}/Microsoft.CSharp.targets.patch"
	eapply "${FILESDIR}/${PV}/Microsoft.Common.targets.patch"
	sed -i 's/CurrentAssemblyVersion = "15.1.0.0"/CurrentAssemblyVersion = "${VER}"/g' "${S}/src/Shared/Constants.cs" || die
	sed -i 's/Microsoft.Build.Tasks.Core, Version=15.1.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a/Microsoft.Build.Tasks.Core, Version=${VER}, Culture=neutral, PublicKeyToken=0738eb9f132ed756/g' "${S}/src/Tasks/Microsoft.Common.tasks" || die
	sed -i 's/PublicKeyToken=b03f5f7f11d50a3a/PublicKeyToken=0738eb9f132ed756/g' "${S}/src/Build/Resources/Constants.cs" || die
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
		CONFIGURATION=Debug
		if use developer; then
			SARGS=${SARGS} /p:DebugType=full
		fi
	else
		CONFIGURATION=Release
		if use developer; then
			SARGS=${SARGS} /p:DebugType=pdbonly
		fi
	fi

	exbuild_raw /v:detailed /p:TargetFrameworkVersion=v4.6 "/p:Configuration=${CONFIGURATION}" ${SARGS} "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:AssemblyOriginatorKeyFile=${KEY2}" "${S}/${PROJ2_DIR}/mono-${PROJ2}.csproj"
	sn -R "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll" "${KEY2}" || die
}

src_install() {
	if use debug; then
		CONFIGURATION=Debug
	else
		CONFIGURATION=Release
	fi

	egacinstall "${PROJ1_DIR}/bin/${CONFIGURATION}/${PROJ1}.dll"

	insinto "$(MSBuildBinPath)"
	newins "${PROJ2_DIR}/bin/${CONFIGURATION}/${PROJ2}.exe" MSBuild.exe
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
