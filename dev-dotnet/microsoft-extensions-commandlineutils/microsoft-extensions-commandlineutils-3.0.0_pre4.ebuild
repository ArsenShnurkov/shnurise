# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} debug developer"

inherit eutils xbuild

GITHUB_ACCOUNT="aspnet"
GITHUB_REPONAME="Extensions"
HOMEPAGE="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}"
EGIT_COMMIT="fd0366daae4c9d47eba72ea6034002cbd7492018"
SRC_URI="https://codeload.github.com/${GITHUB_ACCOUNT}/${GITHUB_REPONAME}/tar.gz/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_REPONAME}-${EGIT_COMMIT}"

