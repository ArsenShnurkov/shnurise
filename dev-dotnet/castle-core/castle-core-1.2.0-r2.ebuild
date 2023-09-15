# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="amd64 ~x86"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"

IUSE="+${USE_DOTNET} +pkg-config"

inherit xbuild gac mono-pkg-config

REPO_NAME="Castle.Core-READONLY"
EGIT_COMMIT="44859cac767ff02dfc43911c4ce4a571625648b0"
SRC_URI="https://github.com/castleproject/${REPO_NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	https://github.com/mono/mono/raw/main/mcs/class/mono.snk"
S="${WORKDIR}/${REPO_NAME}-${EGIT_COMMIT}"

HOMEPAGE="http://www.castleproject.org/"
DESCRIPTION="including Castle DynamicProxy, Logging Services and DictionaryAdapter "
LICENSE="Apache-2.0" # https://github.com/castleproject/Core/blob/master/LICENSE

COMMON_DEPEND="
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	>=dev-util/mono-packaging-tools-1.4.2.2
"

function metafile_to_build(){
	# echo "src/Core-vs2008.sln"
	echo "src/Castle.Core/Castle.Core-vs2008.csproj"
}

function assembly_name() {
	echo "src/Castle.Core/bin/$(usedebug_tostring)/Castle.Core.dll"
}

function signing_key() {
	echo "${FILESDIR}/CastleKey.snk"
}

src_prepare() {
	sed -i 's?System\.configuration?System.Configuration?g' "src/Castle.Core/Castle.Core-vs2008.csproj" || die
	sed -i 's?System\.configuration?System.Configuration?g' "src/Castle.Core.Tests/Castle.Core.Tests-vs2008.csproj" || die
	mpt-csproj ./src --remove-warnings-as-errors || die "removing warning-as-error failed"
	mpt-csproj ./src --remove-signing || die "removing signing failed"
	mpt-csproj ./src --inject-import='/usr/lib/mono/xbuild/MSBuildCommunityTasks/MSBuild.Community.Tasks.Targets' || die "injecting import falied"
	mpt-csproj ./src --inject-versioning=VersionNumber || die "injecting versioning falied"
	mpt-csproj ./src/Castle.Core --inject-InternalsVisibleTo=Castle.Core.Tests "--AssemblyOriginatorKeyFile=$(signing_key)" || die
	eapply_user
}

src_compile() {
	exbuild /p:SignAssembly=true /p:AssemblyOriginatorKeyFile=$(signing_key) /p:VersionNumber=${PV}.0 \
		"/p:RootPath=${S}/src" "$(metafile_to_build)"
	sn -R "$(assembly_name)" "$(signing_key)" || die
}

src_install() {
	egacinstall "$(assembly_name)"
	elib "$(assembly_name)"
}
