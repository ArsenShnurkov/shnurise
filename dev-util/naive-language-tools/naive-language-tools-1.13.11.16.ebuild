# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug"

GITHUB_ACCOUNT_NAME=macias
GITHUB_REPOSITORY_NAME=NaiveLanguageTools
EGIT_COMMIT="d40aadc15824361639b766a4bbe4b1f69a68d996"
SRC_URI="https://github.com/${GITHUB_ACCOUNT_NAME}/${GITHUB_REPOSITORY_NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz"

HOMEPAGE="https://github.com/macias/NaiveLanguageTools"
DESCRIPTION="Free, open-source C# lexer and GLR parser suite"
LICENSE="MIT"

S="${WORKDIR}/${GITHUB_REPOSITORY_NAME}-${EGIT_COMMIT}"

inherit xbuild mono-pkg-config

src_prepare() {
	eapply "${FILESDIR}/variant.patch"
	eapply_user
}

src_compile() {
	exbuild "NaiveLanguageTools.sln"
}

src_install() {
	# ${CATEGORY} == dev-util, not the same as dev-dotnet
	local FINAL_DLL_PATH="/usr/share/dev-dotnet/${PN}"
	local FINAL_EXE_DIRECTORY="/usr/share/${PN}"
	local FINAL_EXE_FILENAME="NaiveLanguageTools.Generator.exe"

	elib "./NaiveLanguageTools.Generator/bin/Release/NaiveLanguageTools.MultiRegex.dll"
	elib "./NaiveLanguageTools.Generator/bin/Release/NaiveLanguageTools.Common.dll"
	elib "./NaiveLanguageTools.Generator/bin/Release/NaiveLanguageTools.Parser.dll"
	elib "./NaiveLanguageTools.Generator/bin/Release/NaiveLanguageTools.Lexer.dll"
	dosym "${FINAL_DLL_PATH}/NaiveLanguageTools.MultiRegex.dll" "${FINAL_EXE_DIRECTORY}/NaiveLanguageTools.MultiRegex.dll"
	dosym "${FINAL_DLL_PATH}/NaiveLanguageTools.Common.dll" "${FINAL_EXE_DIRECTORY}/NaiveLanguageTools.Common.dll"
	dosym "${FINAL_DLL_PATH}/NaiveLanguageTools.Parser.dll" "${FINAL_EXE_DIRECTORY}/NaiveLanguageTools.Parser.dll"
	dosym "${FINAL_DLL_PATH}/NaiveLanguageTools.Lexer.dll" "${FINAL_EXE_DIRECTORY}/NaiveLanguageTools.Lexer.dll"

	insinto "${FINAL_EXE_DIRECTORY}"
	newins NaiveLanguageTools.Generator/bin/Release/NaiveLanguageTools.Generator.exe "${FINAL_EXE_FILENAME}"

	if use debug; then
		make_wrapper nltg "/usr/bin/mono --debug ${FINAL_EXE_DIRECTORY}/${FINAL_EXE_FILENAME}"
	else
		make_wrapper nltg "/usr/bin/mono ${FINAL_EXE_DIRECTORY}/${FINAL_EXE_FILENAME}"
	fi
}
