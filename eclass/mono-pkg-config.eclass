# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: mono-pkg-config.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for registring in gac
# @DESCRIPTION:
# interacts with pkg-config tools

case ${EAPI:-0} in
	0|1|2|3|4|5) die "this eclass doesn't support EAPI ${EAPI:-0}" ;;
	6) ;;
esac

IUSE+=" pkg-config symlink"

DEPEND+=" dev-lang/mono"
RDEPEND+=" dev-lang/mono"

# http://www.gossamer-threads.com/lists/gentoo/dev/263462
# pkg config files should always come from upstream
# but what if they are not?
# you can fork, or you can use a configuration system that upstream actually supports.
# both are more difficult than creating .pc in ebuilds. Forks requires maintenance, and 
# second one requires rewriting the IDE (disrespecting the decision of IDE's authors who decide to use .pc-files)
# So, "keep fighting the good fight, don't stop believing, and let the haters hate" (q) desultory from #gentoo-dev-help @ freenode

if [ "${SLOT}" != "0" ]; then
	APPENDIX="-${SLOT}"
fi

# @FUNCTION: einstall_pc_file
# @DESCRIPTION:  installs .pc file
# The file format contains predefined metadata keywords and freeform variables (like ${prefix} and ${exec_prefix})
# $1 = ${PN}
# $2 = ${PV}
# $3 = myassembly1 # path and filename with extension of the first .dll
# $4 = myassembly2 # path and filename with extension of the second .dll
# $N = myassemblyN-2 # see DLL_REFERENCES
einstall_pc_file()
{
	if use pkg-config; then
		local PC_NAME="$1"
		local PC_VERSION="$2"
		local PC_DESCRIPTION="${DESCRIPTION}"

		local PC_INTERNAL_NAME="${PN}"

		# keep verbatim, do not change it to "/usr/$(get_libdir)/pkgconfig"
		local PC_DIRECTORY="/usr/lib/pkgconfig"

		local PC_FILENAME="${CATEGORY}-${PN}"
		local PC_FILENAME_WITH_SLOT="${PC_FILENAME}${APPENDIX}"

		PC_DIRECTORY_VER="${PC_DIRECTORY}/${PC_FILENAME_WITH_SLOT}"

		shift 2
		if [ "$#" == "0" ]; then
			die "no assembly names given"
		fi
		local DLL_REFERENCES=""
		while (( "$#" )); do
			DLL_REFERENCES+=" -r:${1}"
			shift
		done

		dodir "${PC_DIRECTORY}"
		dodir "${PC_DIRECTORY_VER}"

		ebegin "Installing ${PC_FILENAME_WITH_SLOT}.pc file"

		# @Name@: A human-readable name for the library or package. This does not affect usage of the pkg-config tool,
		# which uses the name of the .pc file.
		# see https://people.freedesktop.org/~dbn/pkg-config-guide.html

		# \${name} variables going directly into .pc file after unescaping $ sign
		#
		# other variables are not substituted to sed input directly
		# to protect them from processing by bash
		# (they only requires sed escaping for replacement path)
		sed \
			-e "s:@PC_VERSION@:${PC_VERSION}:" \
			-e "s:@Name@:${PC_INTERNAL_NAME}:" \
			-e "s:@DESCRIPTION@:${PC_DESCRIPTION}:" \
			-e "s:@LIBDIR@:$(get_libdir):" \
			-e "s*@LIBS@*${DLL_REFERENCES}*" \
			<<-EOF >"${D}/${PC_DIRECTORY_VER}/${PC_FILENAME_WITH_SLOT}.pc" || die
				prefix=\${pcfiledir}/../..
				exec_prefix=\${prefix}
				libdir=\${exec_prefix}/@LIBDIR@
				Version: @PC_VERSION@
				Name: @Name@
				Description: @DESCRIPTION@
				Libs: @LIBS@
			EOF

		einfo PKG_CONFIG_PATH="${D}/${PC_DIRECTORY_VER}" pkg-config --exists "${PC_FILENAME_WITH_SLOT}"
		PKG_CONFIG_PATH="${D}/${PC_DIRECTORY_VER}" pkg-config --exists "${PC_FILENAME_WITH_SLOT}" || die ".pc file failed to validate."
		eend $?

		if use symlink; then
			if [ "${PC_FILENAME}" != "PC_FILENAME_WITH_SLOT" ]; then
				einfo "SymLinking ${PC_DIRECTORY_VER}/${PC_FILENAME_WITH_SLOT}.pc file as ${PC_DIRECTORY}/${PC_FILENAME}.pc"
				dosym "${PC_DIRECTORY_VER}/${PC_FILENAME_WITH_SLOT}.pc" "${PC_DIRECTORY}/${PC_FILENAME}.pc"
			fi
		fi
	fi
}

# @FUNCTION: elib
# @DESCRIPTION: installs .dll file into filesystem
# $1 = path to assembly file to install
elib () {
	local INSTALL_PATH="/usr/$(get_libdir)/dev-dotnet/${PN}${APPENDIX}"
	einfo "installing into ${INSTALL_PATH}"
	insinto "${INSTALL_PATH}"
	local DLL_LIST
	# https://unix.stackexchange.com/questions/128204/what-does-while-test-gt-0-do/128207
	while ${1+:} false ; do
		# https://stackoverflow.com/questions/2664740/extract-file-basename-without-path-and-extension-in-bash
		local ASSEMBLY_FILENAMEWEXT="${1##*/}"
		local ASSEMBLY_FILENAME="${ASSEMBLY_FILENAMEWEXT%.*}"
		einfo "as ${ASSEMBLY_FILENAMEWEXT} and ${ASSEMBLY_FILENAME}"
		doins "$1"
		einfo "elib: $1 is installed as ${INSTALL_PATH}/${ASSEMBLY_FILENAMEWEXT}"
		DLL_LIST+=" ${INSTALL_PATH}/${ASSEMBLY_FILENAMEWEXT}"
		shift
	done
	einstall_pc_file "${PN}" "${PV}" ${DLL_LIST}
	einfo "elib: .pc-file is created"
}
