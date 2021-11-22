# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="1"
if [ "${SLOT}" != "0" ]; then
	APPENDIX="-${SLOT}"
fi

USE_DOTNET="net45"

# cli = do install command line interface
IUSE="+${USE_DOTNET} +pkg-config +symlink +cli debug developer"

inherit xbuild mono-pkg-config

NAME="slntools"
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"

EGIT_COMMIT="705869e96a2f0e401be03f8e8478df3e1f2b9373"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${CATEGORY}-${PN}-${PV}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="library for merging .sln files, and cli-tool"
LICENSE="MIT" # https://github.com/ArsenShnurkov/slntools/blob/master/LICENSE

CDEPEND=""
RDEPEND="${CDEPEND}"
DEPEND="${CDEPEND}
	sys-apps/sed"

SLN_FILE=SLNTools.sln
METAFILETOBUILD="${S}/Main/${SLN_FILE}"

src_prepare() {
	eapply "${FILESDIR}/remove-wix-project-from-sln-file.patch"

	# System.EntryPointNotFoundException: GetStdHandle
	#   at (wrapper managed-to-native) CWDev.SLNTools.CommandLine.Parser:GetStdHandle (int)
	#   at CWDev.SLNTools.CommandLine.Parser.GetConsoleWindowWidth () [0x00000] in <filename unknown>:0 
	#   at CWDev.SLNTools.CommandLine.Parser.ArgumentsUsage (System.Type argumentType) [0x00000] in <filename unknown>:0 
	#   at CWDev.SLNTools.Program.Main (System.String[] args) [0x00000] in <filename unknown>:0 
	# http://stackoverflow.com/questions/23824961/c-sharp-to-mono-getconsolewindow-exception
	eapply "${FILESDIR}/console-window-width.patch"

	# no need to restore if all dependencies are from GAC
	# nuget restore "${METAFILETOBUILD}" || die

	default
}

src_compile() {
	ARGS=""
	ARGSN=""

	if use debug; then
		ARGS="${ARGS} /p:Configuration=Debug"
		ARGSN="${ARGSN} Configuration=Debug"
	else
		ARGS="${ARGS} /p:Configuration=Release"
		ARGSN="${ARGSN} Configuration=Release"
	fi

	if use developer; then
		ARGS="${ARGS} /p:DebugSymbols=True"
	else
		ARGS="${ARGS} /p:DebugSymbols=False"
	fi

	exbuild ${ARGS} ${METAFILETOBUILD}
}

src_install() {
	default

	elib Main/SLNTools.exe/bin/$(usedebug_tostring)/CWDev.SLNTools.Core.dll
	elib Main/SLNTools.exe/bin/$(usedebug_tostring)/CWDev.SLNTools.UIKit.dll

	if use cli; then
		insinto "$(executable_assembly_dir)"
		dosym "$(library_assembly_dir)/CWDev.SLNTools.Core.dll" "$(executable_assembly_dir)/CWDev.SLNTools.Core.dll"
		dosym "$(library_assembly_dir)/CWDev.SLNTools.UIKit.dll" "$(executable_assembly_dir)/CWDev.SLNTools.UIKit.dll"
		doins "Main/SLNTools.exe/bin/$(usedebug_tostring)/SLNTools.exe"
		make_wrapper slntools "mono /usr/share/slntools/SLNTools.exe"
	fi
}

# Usage:
# SLNTools.exe 
# @<file>    Read response file for more options
# <Command>  Command Name (CompareSolutions|MergeSolutions|CreateFilterFileFromSolution|EditFilterFile|OpenFilterFile|SortProjects)
