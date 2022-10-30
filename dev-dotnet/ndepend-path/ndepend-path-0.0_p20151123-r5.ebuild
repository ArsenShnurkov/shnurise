# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="amd64"
RESTRICT="mirror"

SLOT="1"

USE_DOTNET="net45"
IUSE=" debug +${USE_DOTNET} +pkg-config +symlink"

inherit dotnet
inherit mono-pkg-config

NAME="NDepend.Path"

DESCRIPTION="C# framework for paths operations: Absolute, Drive Letter, UNC, Relative, prefix"
LICENSE="MIT" # https://github.com/psmacchia/NDepend.Path/blob/master/LICENSE
HOMEPAGE="https://github.com/psmacchia/${NAME}"
EGIT_COMMIT="96008fcfbc137eac6fd327387b80b14909a581a1"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz
	"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

PROJECT_REL_DIR=${NAME}
ASSEMBLY_NAME=${NAME}

function bin_dir ( ) {
	echo "${WORKDIR}/bin/$(usedebug_tostring)"
}

function output_filename ( ) {
	echo "$(bin_dir)/${ASSEMBLY_NAME}.dll"
}

src_prepare() {
	rm "${S}/NDepend.Path/NDepend.Helpers/IReadOnlyList.cs" || die

	sed -i '1 i\using System.Collections.Generic;' NDepend.Path/NDepend.Path/PathHelpers.cs || die

	eapply_user
}

src_compile() {
	einfo "Compiling $(output_filename)"
	mkdir -p $(bin_dir) || die
	csc $(csharp_sources "${S}/${PROJECT_REL_DIR}") \
		/t:library /out:$(output_filename) || die
}

src_install() {
	local INSTALL_DIR="$(anycpu_current_assembly_dir)"

	insinto "${INSTALL_DIR}"
	elib2 "${INSTALL_DIR}" "$(output_filename)"

	dosym "${INSTALL_DIR}/${ASSEMBLY_NAME}.dll" "$(anycpu_current_symlink_dir)/${ASSEMBLY_NAME}.dll"

	# einstall_pc_file "${CATEGORY}/${PN}"
	einstall_pc_file "${ASSEMBLY_NAME}" "${VERSION}" /usr/share/mono/assemblies/${PN}${APPENDIX}/${ASSEMBLY_NAME}.dll
}
