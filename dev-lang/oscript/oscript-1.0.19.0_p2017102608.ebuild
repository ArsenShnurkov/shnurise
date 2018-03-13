# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer"

inherit multilib eutils 
inherit msbuild

HOMEPAGE="http://oscript.io"
#SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/${CATEGORY}/${PN}${APPENDIX}/${PN}-${PV}.tar.gz -> ${CATEGORY}-${PN}${APPENDIX}.tar.gz"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/${CATEGORY}/${PN}/${PN}-${PV}.tar.gz -> ${CATEGORY}-${PN}${APPENDIX}.tar.gz"

DESCRIPTION="scripting interpreter for 1C-like language (mono based)"
LICENSE="MPL-2.0" # https://github.com/EvilBeaver/OneScript/blob/develop/LICENSE

COMMON_DEPEND="
	dev-dotnet/newtonsoft-json
	dev-dotnet/dotnetzip-semverd
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

src_prepare() {
	eapply_user
}

src_compile() {
	emsbuild "src/1Script_Mono.sln"
}

src_install() {
	insinto "/usr/share/${PN}${APPENDIX}"
	doins "${S}/src/oscript/bin/x86/Release/oscript.exe"
	doins "${S}/src/oscript/bin/x86/Release/oscript.cfg"
	doins "${S}/src/oscript/bin/x86/Release/OneScript.DebugProtocol.dll"
	doins "${S}/src/oscript/bin/x86/Release/ScriptEngine.dll"
	doins "${S}/src/oscript/bin/x86/Release/ScriptEngine.HostedScript.dll"
	if use developer ; then
		doins "${S}/src/oscript/bin/x86/Release/oscript.pdb"
		doins "${S}/src/oscript/bin/x86/Release/OneScript.DebugProtocol.pdb"
		doins "${S}/src/oscript/bin/x86/Release/ScriptEngine.pdb"
		doins "${S}/src/oscript/bin/x86/Release/ScriptEngine.HostedScript.pdb"
	fi

	if use debug; then
		make_wrapper oscript "/usr/bin/mono --debug \${MONO_OPTIONS} /usr/share/${PN}${APPENDIX}/oscript.exe"
	else
		make_wrapper oscript "/usr/bin/mono \${MONO_OPTIONS} /usr/share/${PN}${APPENDIX}/oscript.exe"
	fi
}
