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
IUSE="debug gac nupkg"
KEYWORDS="amd64 ppc x86"
DEPEND="|| ( >=dev-lang/mono-3.4.0 <dev-lang/mono-9999 )	"
RDEPEND="${DEPEND}"

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
	if use debug; then
		exbuild /p:DebugSymbols=True ${METAFILETOBUILD}
	else
		exbuild /p:DebugSymbols=False ${METAFILETOBUILD}
	fi
	if use nupkg; then
		elog "Building nuget package because USE=nupkg specified"
		elog "nuget pack ${FILESDIR}/ICSharpCode.TextEditor.nuspec -BasePath "${S}" -OutputDirectory ${WORKDIR} -NonInteractive -Verbosity detailed"
		nuget pack ${FILESDIR}/ICSharpCode.TextEditor.nuspec -BasePath "${S}" -OutputDirectory ${WORKDIR} -NonInteractive -Verbosity detailed
		# Successfully created package '/var/tmp/portage/dev-dotnet/icsharpcodetexteditor-1.0.1-r20150630/work/ICSharpCode.TextEditor.dll.4.0.2.6466.nupkg'.
		#                               /var/tmp/portage/dev-dotnet/icsharpcodetexteditor-1.0.1-r20150630/work/*.nupkg
	fi
}

src_install() {
	if use gac; then
		egacinstall Project/bin/Release/ICSharpCode.TextEditor.dll
	fi
	if use nupkg; then
		if [ -d "/var/calculate/remote/distfiles" ]; then
			# Control will enter here if the directory exist.
			# this is necessary to handle calculate linux profiles feature (for corporate users)
			elog "Installing .nupgk into /var/calculate/remote/distfiles/NuGet"
			insinto /var/calculate/remote/distfiles/NuGet
		else
			# this is for all normal gentoo-based distributions
			elog "Installing .nupgk into /usr/local/nuget/nupkg"
			insinto /usr/local/nuget/nupkg
		fi
		# star (*.nupkg) is used because of ".dll.4.0.2.6466" substring, see comment in src_compile() section
		doins "${WORKDIR}/ICSharpCode.TextEditor.dll.4.0.2.6466.nupkg"
	fi
}
