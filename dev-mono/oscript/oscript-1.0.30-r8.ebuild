# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="~amd64"
RESTRICT="mirror"

SLOT="1.30"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer"

inherit multilib
inherit dotnet

HOMEPAGE="https://github.com/EvilBeaver/OneScript"

GITHUB_REPONAME="OneScript"
GITHUB_ACCOUNT="EvilBeaver"
EGIT_COMMIT="85b3088532a7c97574ea837945745622beba9f2c"

SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

DESCRIPTION="scripting interpreter for 1C-like language (mono based)"
LICENSE="MPL-2.0" # https://github.com/EvilBeaver/OneScript/blob/develop/LICENSE

COMMON_DEPEND="
	dev-dotnet/newtonsoft-json
	>=dev-dotnet/dotnetzip-semverd-1.9.3-r4
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	rm -rf "${S}/src/ScriptEngine.HostedScript/Library/Zip" || die
	eapply_user
}

# OneScript.Language\OneScript.Language.csproj -> OneScript.Language.dll
function references_language () {
	echo -n \
		$(reference_framework System)
}

# ScriptEngine\ScriptEngine.csproj -> ScriptEngine.dll
function references_engine () {
	echo -n \
		$(reference_project OneScript.Language) \
		$(reference_framework System)
}

# ScriptEngine.HostedScript\ScriptEngine.HostedScript.csproj -> ScriptEngine.HostedScript.dll
function references_script () {
	echo -n \
		$(reference_dependency Newtonsoft.Json) \
		$(reference_dependency Ionic.Zip.Reduced-13) \
		$(reference_project OneScript.Language) \
		$(reference_project ScriptEngine) \
		$(reference_framework System)
}

# OneScript.DebugProtocol\OneScript.DebugProtocol.csproj -> OneScript.DebugProtocol.dll
function references_protocol () {
	echo -n \
		$(reference_framework System.ServiceModel) \
		$(reference_framework System)
}

# OneScript.DebugServices\OneScript.DebugServices.csproj -> OneScript.DebugServices.dll
#function references_services () {
#	echo -n \
#		$(reference_framework System)
#}

function references_util () {
	echo -n \
		$(reference_dependency Newtonsoft.Json) \
		$(reference_project OneScript.Language) \
		$(reference_project ScriptEngine) \
		$(reference_project ScriptEngine.HostedScript) \
		$(reference_project OneScript.DebugProtocol) \
		$(reference_framework System)
}

src_compile() {
	mkdir -p $(bin_dir) || die
	ecsc $(references_language) $(csharp_sources src/OneScript.Language) $(output_dll OneScript.Language)
	ecsc $(references_engine) $(csharp_sources src/ScriptEngine) $(output_dll ScriptEngine)
	ecsc $(references_script) $(csharp_sources src/ScriptEngine.HostedScript) $(output_dll ScriptEngine.HostedScript)
	ecsc $(references_protocol) $(csharp_sources src/OneScript.DebugProtocol) $(output_dll OneScript.DebugProtocol)
#	ecsc $(references_services) $(csharp_sources src/OneScript.DebugServices) $(output_dll OneScript.DebugServices)
	ecsc $(references_util) $(csharp_sources src/oscript) $(output_exe oscript)
}

src_install() {
	local INSTALL_PATH="/usr/share/${PN}${APPENDIX}"
	insinto ${INSTALL_PATH}
	doins "${S}/src/ScriptEngine.HostedScript/oscript.cfg"
	doins "$(bin_dir)/oscript.exe"
#	doins "$(bin_dir)/OneScript.DebugServices.dll"
	doins "$(bin_dir)/OneScript.DebugProtocol.dll"
	doins "$(bin_dir)/ScriptEngine.HostedScript.dll"
	doins "$(bin_dir)/ScriptEngine.dll"
	doins "$(bin_dir)/OneScript.Language.dll"
#	if use developer ; then
#		doins "$(bin_dir)/oscript.pdb"
#		doins "$(bin_dir)/OneScript.DebugProtocol.pdb"
#		doins "$(bin_dir)/ScriptEngine.pdb"
#		doins "$(bin_dir)/OneScript.Language.pdb"
#		doins "$(bin_dir)/ScriptEngine.HostedScript.pdb"
#	fi

	if use debug; then
		make_wrapper oscript "/usr/bin/mono --debug \${MONO_OPTIONS} ${INSTALL_PATH}/oscript.exe"
	else
		make_wrapper oscript "/usr/bin/mono \${MONO_OPTIONS} ${INSTALL_PATH}/oscript.exe"
	fi
}
