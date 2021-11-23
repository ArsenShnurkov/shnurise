# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
KEYWORDS="amd64 ~arm64"
RESTRICT="test mirror"

DESCRIPTION="An utility to generate .cs from .resx"
HOMEPAGE="https://github.com/ArsenShnurkov/mono-packaging-tools"

LICENSE="GPL-2"

IUSE="developer debug"

if [[ ${PV} == "9999" ]] ; then
	PROPERTIES="live"
	SLOT="9999"
	if [ -n "${SYMLINK_SRC_URI}" ]; then
		einfo '${SYMLINK_SRC_URI}='"${SYMLINK_SRC_URI}"
	else
		inherit git-r3
		EGIT_REPO_URI="https://github.com/ArsenShnurkov/mono-packaging-tools.git"
	fi
else
	SLOT="0"
	SRC_URI=""
fi

USE_DOTNET="net45"
inherit dotnet

BDEPEND=""
RDEPEND=""

src_unpack() {
	einfo '${WORKDIR}='"${WORKDIR}"
	einfo '${S}      ='"${S}"
	einfo '${T}      ='"${T}"
	mkdir -p "${WORKDIR}"
#	mkdir -p "${S}"
	if [ -n "${SYMLINK_SRC_URI}" ]; then
		einfo 'whoami says "'`whoami`'"'
#		einfo 'Symlinking ...'
		einfo "ls -ld /home/user/res2cs"
		einfo `ls -ld /home/user/res2cs`
		einfo "ls -ld /home/user/"
		einfo `ls -ld /home/user/`
		mkdir -p "${S}" || die
		ln -sfn "${SYMLINK_SRC_URI}" "${S}" || die
#		cp -r "${SYMLINK_SRC_URI}" "${S}" || die
		chown -R portage:portage "${S}" || die
	fi
	default
}

src_prepare() {
	default
}

src_compile() {
	mkdir -p "$(bin_dir)" || die

	FRAMEWORK_DIR=/usr/lib/mono/4.8-api
	ecsc $(csharp_sources .)  $(reference_framework ${FRAMEWORK_DIR}/Mono.Options) $(reference_framework System.Design) $(output_exe res2cs)
}

src_install() {
	insinto "$(anycpu_current_assembly_dir)"
	doins "$(bin_dir)/res2cs.exe"

	local MONO="/usr/bin/mono"
	local PROGRAM="$(anycpu_current_assembly_dir)/res2cs.exe"
	local MONO_OPTIONS=""
	if use debug; then
		MONO_OPTIONS="--debug"
	fi
	make_wrapper res2cs "${MONO} ${MONO_OPTIONS} ${PROGRAM}"
}
