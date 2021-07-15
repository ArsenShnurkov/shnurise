# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

IUSE="debug developer pkg-config"

# function elib is used for .dll install
# it in turn calls function einstall_pc_file if USE="pkg-config" is specified
inherit mono-pkg-config

GITHUB_ACCOUNT=zzzprojects
GITHUB_PROJECTNAME=html-agility-pack

KEYWORDS="amd64 arm64"
if [[ ${PV} == 1.11.34 ]] ; then
	SLOT=0
	EGIT_COMMIT=f5f4776fa9d444af2a11f0f18cfb1c2a2717d97c
else
	KEYWORDS="~amd64 ~arm64"
	if [[ ${PV} == 1.11.34_p6 ]] ; then
		SLOT=6
		EGIT_COMMIT=bd8bec435e2436a6be92f47e8c3c727b602ba52e
	else
		if [[ ${PV} == 9999 ]] ; then
			SLOT=9999
			EGIT_REPO_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}.git"
			# EGIT_REPO_URI="git://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}.git"
			# EGIT_REPO_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}"
			KEYWORDS="~amd64 ~arm64"
		else
			equwarn "Ebuild Version $${PV}=""${PV}"" should be reviewed"
		fi
	fi
fi

einfo "\${SLOT}: ${SLOT}"

if [[ ${PV} == 9999 ]] ; then
	inherit git-r3
else
	RESTRICT=mirror
	if [ -z ${EGIT_COMMIT+x} ] ; then
		# try extract by tag
		SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/v${PV}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz"
		S="${WORKDIR}/${PN}-v${PV}"
	else
		# extract by SHA1
		SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz"

		# vcs-snapshot.eclass will strip that first dir level and re-add /${P} , so default S works
		# eg instead of unpacking to $WORKDIR/foo-dc8s9ee1/ , it will unpack to $WORKDIR/foo-1.2.3/ as expected
#		inherit vcs-snapshot
		S="${WORKDIR}/${PN}-${EGIT_COMMIT}"
	fi
fi

HOMEPAGE="https://html-agility-pack.net/"
DESCRIPTION="Html Agility Pack is a C# parser for HTML, supports plain XPATH and XSLT"
LICENSE="MIT"

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196"
RDEPEND="${COMMON_DEPEND}"
DEPEND="${COMMON_DEPEND}"

src_unpack() {
	default
	if [[ ${PV} == 9999 ]] ; then
		git-r3_fetch
		git-r3_checkout
	fi
	if [ -d "${S}" ] ; then
		einfo "Directory ${S} exists"
	else
		einfo "Directory ""${S}"" doesn't exist"
	fi
}

src_prepare() {
	eapply_user
}

inherit msbuild

src_compile() {
	emsbuild "src/HtmlAgilityPack.Net45/HtmlAgilityPack.Net45.csproj"
}

# https://stackoverflow.com/a/21941473/4158543
anycpu_outputnames()
{
	declare -a ANYCPU_OUTPUTNAMES
	ANYCPU_OUTPUTNAMES+=("HtmlAgilityPack")
	echo ${ANYCPU_OUTPUTNAMES[@]}
}

anycpu_outputpaths()
{
	declare -a ANYCPU_OUTPUTPATHS
	ANYCPU_OUTPUTPATHS+=("${S}/src/HtmlAgilityPack.Net45/bin/$(usedebug_tostring)/HtmlAgilityPack.dll")
	echo ${ANYCPU_OUTPUTPATHS[@]}
}

src_install() {
	local INSTALL_DIR="$(anycpu_current_assembly_dir)"
	insinto "${INSTALL_DIR}"

	einfo "=== making .pc file for all libraries at once ==="
	einfo "$(anycpu_current_assembly_dir)" $(anycpu_outputpaths)
	elib "$(anycpu_current_assembly_dir)" $(anycpu_outputpaths)

	einfo "=== symlink each output separately ==="
	for OUTPUT_NAME in $(anycpu_outputnames)
	do
		einfo "Symlinking ${OUTPUT_NAME}"
		dosym "${INSTALL_DIR}/${OUTPUT_NAME}.dll" "$(anycpu_current_symlink_dir)/${OUTPUT_NAME}.dll"
	done
}
