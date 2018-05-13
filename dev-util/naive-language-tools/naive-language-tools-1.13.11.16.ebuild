# Copyright 1999-2018 Gentoo Foundation
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

inherit xbuild

src_prepare() {
	eapply_user
}

src_compile() {
	exbuild "NaiveLanguageTools.sln"
}

src_install() {
	insinto "/usr/share/${PN}"
	if use debug; then
		:
#		newins bin/Debug/Gppg.exe Gppg.exe
#		make_wrapper gppg "/usr/bin/mono --debug /usr/share/${PN}/gppg.exe"
	else
		:
#		newins bin/Release/Gppg.exe gppg.exe
#		make_wrapper gppg "/usr/bin/mono /usr/share/${PN}/gppg.exe"
	fi
}
