# Copyright 1999-2019 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"
KEYWORDS="~amd64 ~x86"
RESTRICT+=" mirror"

SLOT="0"

COMMON_DEPEND="
"
DEPEND="${COMMON_DEPEND}
"
RDEPEND="${COMMON_DEPEND}
"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET} +pkg-config debug"

# dotnet.eclass adds dependency "dev-lang/mono" and allows to use C# compiler
inherit dotnet
# mono-pkg-config allows to install .pc-files for monodevelop
inherit mono-pkg-config

HOMEPAGE="https://github.com/JeremySkinner/Ssh-Config-Parser"
DESCRIPTION="C#/.NET parser for OpenSSH config files"
LICENSE="MIT"

REPO_NAME="Ssh-Config-Parser"
REPO_OWNER="JeremySkinner"
REPOSITORY="https://github.com/${REPO_OWNER}/${NAME}"
LICENSE_URL="${REPOSITORY}/blob/master/LICENSE"

EGIT_COMMIT="04152ebc42ff81b11497cdbacfeb7ab95e79b37f"
EGIT_SHORT_COMMIT=${EGIT_COMMIT:0:7}
SRC_URI="https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/tarball/${EGIT_COMMIT} -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${REPO_OWNER}-${REPO_NAME}-${EGIT_SHORT_COMMIT}"

RESTRICT+=" test"

ASSEMBLY_NAMES=("Ssh.Config.Parser")
DQUOTE='"'

src_compile() {
	local PARAMETERS="/target:library"
	PARAMETERS+=" /recurse:${S}/SshConfigParser/*.cs"
	if (use debug); then
		PARAMETERS+=" /debug:full"
	fi
        PARAMETERS+=" /out:${DQUOTE}${WORKDIR}/${ASSEMBLY_NAMES[0]}.dll${DQUOTE}"
	einfo ${PARAMETERS}
	/usr/bin/csc ${PARAMETERS} || die "compilation failed"
}

src_install() {
	insinto $(library_assembly_dir)
	for assembly_name in ${ASSEMBLY_NAMES[*]} ; do
		ASSEMBLY_NAME="${WORKDIR}/${assembly_name}"
		einfo "installing  ${DQUOTE}${ASSEMBLY_NAME}.dll${DQUOTE}"
		doins "${ASSEMBLY_NAME}.dll"
		if (use debug); then
			einfo "installing  ${DQUOTE}${ASSEMBLY_NAME}.pdb${DQUOTE}"
			doins "${ASSEMBLY_NAME}.pdb"
		fi
	done
	einstall_pc_file "${PN}" "1.0" ${ASSEMBLY_NAMES[*]}
}
