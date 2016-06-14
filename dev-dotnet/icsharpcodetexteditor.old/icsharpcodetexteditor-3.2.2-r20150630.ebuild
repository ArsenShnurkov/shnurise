# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit eutils dotnet

DESCRIPTION="ICSharpCode.TextEditor library"
LICENSE="MIT"

PROJECTNAME="ICSharpCode.TextEditor"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="24903d58cddab7d0ff17fc96a8bb25f66e6eea56"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"

SLOT="0"
KEYWORDS="amd64 ppc x86"
DEPEND="|| ( >=dev-lang/mono-3.4.0 <dev-lang/mono-9999 )	"
RDEPEND="${DEPEND}"
USE_DOTNET="net45"
IUSE="${USE_DOTNET} debug developer gac nupkg"

S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

METAFILETOBUILD=ICSharpCode.TextEditor.sln

# https://devmanual.gentoo.org/ebuild-writing/variables/
#
# PN = Package name, for example vim.
# P = Package name and version (excluding revision, if any), for example vim-6.3.
# FILESDIR = Path to the ebuild's files/ directory, commonly used for small patches and files. Value: "${PORTDIR}/${CATEGORY}/${PN}/files"
# WORKDIR = Path to the ebuild's root build directory. Value: "${PORTAGE_BUILDDIR}/work"
# S = Path to the temporary build directory, used by src_compile and src_install. Default: "${WORKDIR}/${P}".

#src_prepare() {
# patch is from another project and will not apply to this one. new patch should be created for this project
#	if use gac; then
#		elog "Setting strong name key"
#		epatch "${FILESDIR}/add-keyfile-option-to-csproj.patch"
#	fi
#}

src_compile() {
	exbuild ${METAFILETOBUILD}
	enupkg "${FILESDIR}/ICSharpCode.TextEditor.nuspec"
}

src_install() {
	if use gac; then
		egacinstall Project/bin/Release/ICSharpCode.TextEditor.dll
	fi
	if use nupkg; then
		if [ -d "/var/calculate/remote/distfiles" ]; then
			# Control will enter here if the directory exist.
			# this is necessary to handle calculate linux profiles feature (for corporate users)
			elog "Installing .nupkg into /var/calculate/remote/packages/NuGet"
			insinto /var/calculate/remote/packages/NuGet
		else
			# this is for all normal gentoo-based distributions
			elog "Installing .nupgk into /usr/local/nuget/nupkg"
			insinto /usr/local/nuget/nupkg
		fi
		# star (*.nupkg) is used because of ".dll.4.0.2.6466" substring, see comment in src_compile() section
		doins "${WORKDIR}/ICSharpCode.TextEditor.3.2.2.nupkg"
	fi
}
