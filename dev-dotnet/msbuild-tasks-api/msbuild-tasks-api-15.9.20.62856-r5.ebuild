# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
RESTRICT="mirror"
KEYWORDS="amd64"

# see docs:
# https://github.com/gentoo/gentoo/commit/59a1a0dda7300177a263eb1de347da493f09fdee
# https://devmanual.gentoo.org/eclass-reference/eapi7-ver.eclass/index.html
# inherit eapi7-ver

SLOT="$(ver_cut 1-2)"

VER="${SLOT}.0.0" # version of resulting .dll files in GAC

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +mskey +gac +pkg-config debug  developer"

inherit xbuild gac
inherit mono-pkg-config

GITHUB_ACCOUNT="Microsoft"
GITHUB_PROJECTNAME="msbuild"
EGIT_COMMIT="88f5fadfbef809b7ed2689f72319b7d91792460e"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz
	mskey? ( https://github.com/Microsoft/msbuild/raw/master/src/MSFT.snk )
	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
	"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/Microsoft/msbuild"
DESCRIPTION="msbuild libraries for writing Task-derived classes"
LICENSE="MIT" # https://github.com/mono/linux-packaging-msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/system-collections-immutable-2.0.0_pre-r1
"

UT_PROJ=Microsoft.Build.Utilities.Core
FW_PROJ=Microsoft.Build.Framework
UT_DIR=src/Utilities
FW_DIR=src/Framework

src_prepare() {
	einfo "PublicKeyToken=$(token)"
	REGEX='s/PublicKeyToken=[0-9a-f]+/PublicKeyToken='$(token)'/g'
	sed -E ${REGEX} "${FILESDIR}/${PV}/mono-${FW_PROJ}.csproj" > "${S}/${FW_DIR}/mono-${FW_PROJ}.csproj" || die
	sed -E ${REGEX} "${FILESDIR}/${PV}/mono-${UT_PROJ}.csproj" > "${S}/${UT_DIR}/mono-${UT_PROJ}.csproj" || die
	# for $(get_libdir) see https://dev.gentoo.org/~ulm/pms/head/pms.html#x1-13500012.3.15
	sed -i "s:System_Collections_Immutable_dll:/usr/$(get_libdir)/mono/gac/System.Collections.Immutable/2.0.0.0__0738eb9f132ed756/System.Collections.Immutable.dll:g" "${S}/${UT_DIR}/mono-${UT_PROJ}.csproj" || die
	sed -E ${REGEX} -i ${S}/src/MSBuild/app.config || die
	sed -E ${REGEX} -i ${S}/src/Build/Resources/Constants.cs || die
	sed -E ${REGEX} -i ${S}/src/Tasks/Microsoft.Common.tasks || die
	sed -E ${REGEX} -i ${S}/src/Tasks/Microsoft.Common.overridetasks || die
	sed "s/15.1./15.9./g" -i "${S}/src/Shared/Constants.cs" || die
	eapply_user
}

src_compile() {
	if use developer; then
		SARGS=DebugSymbols=True
	else
		SARGS=DebugSymbols=False
	fi

	exbuild_raw /v:detailed /p:MonoBuild=true /p:TargetFrameworkVersion=v4.6 "/p:Configuration=$(usedebug_tostring)" /p:${SARGS} "/p:PublicKeyToken=$(token)" "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:DelaySign=true" "/p:AssemblyOriginatorKeyFile=$(token_key)" "${S}/${FW_DIR}/mono-${FW_PROJ}.csproj"
	sn -R "${S}/${FW_DIR}/bin/$(usedebug_tostring)/${FW_PROJ}.dll" "$(signing_key)" || die
	exbuild_raw /v:detailed /p:MonoBuild=true /p:TargetFrameworkVersion=v4.6 "/p:Configuration=$(usedebug_tostring)" /p:${SARGS} "/p:PublicKeyToken=$(token)" "/p:VersionNumber=${VER}" "/p:RootPath=${S}" "/p:SignAssembly=true" "/p:DelaySign=true" "/p:AssemblyOriginatorKeyFile=$(token_key)" "${S}/${UT_DIR}/mono-${UT_PROJ}.csproj"
	sn -R "${S}/${UT_DIR}/bin/$(usedebug_tostring)/${UT_PROJ}.dll" "$(signing_key)" || die
}

src_install() {
	egacinstall "${S}/${FW_DIR}/bin/$(usedebug_tostring)/${FW_PROJ}.dll"
	egacinstall "${S}/${UT_DIR}/bin/$(usedebug_tostring)/${UT_PROJ}.dll"

	einstall_pc_file "Microsoft.Build.Framework" "${SLOT}" "/usr/lib/mono/msbuild-tasks-api/${FW_PROJ}.dll" "/usr/lib/mono/msbuild-tasks-api/${UT_PROJ}.dll"
}


