# Copyright 1999-2016 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit dotnet

NAME="repository-analyser"
HOMEPAGE="https://github.com/ArsenShnurkov/${NAME}"

EGIT_COMMIT="7423a3da82f5c5c874801fc85482ec89e03f74b8"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${PN}-${PV}.tar.gz"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="modified Earley parser in C# inspired by the Marpa Parser project"
LICENSE="GPLv3" # https://github.com/ArsenShnurkov/repository-analyser/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-4.9.0
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/msbuildtasks
	dev-util/mono-packaging-tools
"
RDEPEND="${COMMON_DEPEND}
"

src_prepare() {
	# instrument .csproj files in specified directory with AssemblyInfoTask
	#empt-csproj -passversion -dir="${S}"
	eapply_user
}

src_compile() {
	exbuild "${S}/RepositoryAnalyser.sln"
}

src_install() {
	insinto "/usr/share/${PN}/slot-${SLOT}"
	if use debug; then
		newins RepositoryAnalyser/bin/Debug/repository-analyser.exe repository-analyser.exe
		make_wrapper repository-analyser "/usr/bin/mono --debug /usr/share/${PN}/slot-${SLOT}/repository-analyser.exe"
	else
		newins RepositoryAnalyser/bin/Release/repository-analyser.exe repository-analyser.exe
		make_wrapper repository-analyser "/usr/bin/mono /usr/share/${PN}/slot-${SLOT}/repository-analyser.exe"
	fi
}
