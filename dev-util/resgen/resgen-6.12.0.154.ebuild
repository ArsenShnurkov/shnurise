# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
RESTRICT="mirror"
KEYWORDS="amd64 arm64"

SLOT="$(ver_cut 1-2)"

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} +symlink developer debug"

inherit dotnet

GITHUB_ACCOUNT="mono"
GITHUB_PROJECTNAME="mono"
# EGIT_COMMIT="1ed1688a543c0c03f8fc0cc8e6ca234a6bd45eb0"
EGIT_COMMIT="0c979e6d769bda97bfba41c29324f727e72e27d8"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/mono/mono"
DESCRIPTION="Resource generator from mono"
LICENSE="MIT" # https://github.com/mono/mono/blob/main/LICENSE

COMMON_DEPEND=""
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

# PATCHES=( "assembly-info.patch" )

src_prepare() {
	eapply "${FILESDIR}/assembly-info.patch"
	sed -i 's/Consts.MonoVersion/"'${PV}'"/g' "${S}/mcs/tools/resgen/monoresgen.cs" || die
	mkdir -p "${S}/mcs/build/common/" || die
	touch "${S}/mcs/build/common/Consts.cs" || die
	eapply_user
}

function references () {
	echo -n \
		$(reference_framework System.Core) \
		$(reference_framework System.Drawing) \
		$(reference_framework System.Xml) \
		$(reference_framework System)
}

#resgen is used in initial msbuild compilation, so can't use .csproj, use direct build with ecsc.
src_compile() {
	mkdir -p "$(bin_dir)" || die

	cd "${S}/mcs/tools/resgen" || die

	# https://stackoverflow.com/questions/30988586/creating-an-array-from-a-text-file-in-bash
	local SOURCES=()
	while IFS= read -r line || [[ "$line" ]]; do
	  SOURCES+=("$line")
	done < resgen.exe.sources

	ecsc -noconfig $(references) /unsafe ${SOURCES[@]} $(output_exe resgen)
}

src_install() {
	local INSTALL_PATH="/usr/share/${PN}${APPENDIX}/"
	insinto ${INSTALL_PATH}
	doins "$(bin_dir)/resgen.exe"

	if use debug; then
		make_wrapper resgen-${SLOT} "/usr/bin/mono --debug ${INSTALL_PATH}/resgen.exe"
	else
		make_wrapper resgen-${SLOT} "/usr/bin/mono ${INSTALL_PATH}/resgen.exe"
	fi

#	local WRAPPER_PATH="${EPREFIX}/usr/bin"
	local WRAPPER_PATH="/usr/bin"
	if use symlink; then
		dosym ${WRAPPER_PATH}/resgen-${SLOT} /usr/bin/resgen || die
	fi
}
