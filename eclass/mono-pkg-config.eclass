# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mono-pkg-config.eclass
# @MAINTAINER: dotnet@gentoo.org
# @BLURB: functions for registring in gac
# @DESCRIPTION:
# interacts with pkg-config tools

case ${EAPI:-0} in
	0|1|2|3|4|5) die "this eclass doesn't support EAPI ${EAPI:-0}" ;;
	6) ;;
esac

IUSE+=" pkg-config"

DEPEND+=" virtual/pkgconfig"

# http://www.gossamer-threads.com/lists/gentoo/dev/263462
# pkg config files should always come from upstream
# but what if they are not?
# you can fork, or you can use a configuration system that upstream actually supports.
# both are more difficult than creating .pc in ebuilds. Forks requires maintenance, and 
# second one requires rewriting the IDE (disrespecting the decision of IDE's authors who decide to use .pc-files)
# So, "keep fighting the good fight, don't stop believing, and let the haters hate" (q) desultory from #gentoo-dev-help @ freenode

# @FUNCTION: einstall_pc_file
# @DESCRIPTION:  installs .pc file
# The file format contains predefined metadata keywords and freeform variables (like ${prefix} and ${exec_prefix})
# $1 = name of package (in terms of pkg-config utility)
# $2 = ${PV}
# $3 = myassembly1 # path and filename with extension of the first .dll
# $4 = myassembly2 # path and filename with extension of the second .dll
# $N = myassemblyN-2 # see DLL_REFERENCES
einstall_pc_file()
{
	if use pkg-config; then
		local PC_NAME="$1"
		local PC_VERSION="$2"
		einfo "PC_NAME=${PC_NAME}, PC_VERSION=${PC_VERSION}"
		shift 2

		local PC_DESCRIPTION="${DESCRIPTION}"

		# keep verbatim, do not change it to "/usr/$(get_libdir)/pkgconfig"
		local PC_DIRECTORY="/usr/share/pkgconfig"

		local PC_FILENAME="${PC_NAME}-${PC_VERSION}"
		local PC_FILENAME_EXT="${PC_FILENAME}.pc"

		if [ "$#" == "0" ]; then
			die "no assembly names given"
		fi
		local DLL_REFERENCES=""
		while (( "$#" )); do
			DLL_REFERENCES+=" -r:${1}"
			shift
		done

		dodir "${PC_DIRECTORY}"

		ebegin "Installing ${PC_FILENAME_EXT} file"

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
			-e "s:@Name@:${PC_NAME}:" \
			-e "s\\@DESCRIPTION@\\${PC_DESCRIPTION}\\" \
			-e "s:@LIBDIR@:$(get_libdir):" \
			-e "s*@LIBS@*${DLL_REFERENCES}*" \
			<<-EOF >"${D}/${PC_DIRECTORY}/${PC_FILENAME_EXT}" || die
				prefix=\${pcfiledir}/../..
				exec_prefix=\${prefix}
				libdir=\${exec_prefix}/@LIBDIR@
				Version: @PC_VERSION@
				Name: @Name@
				Description: @DESCRIPTION@
				Libs: @LIBS@
			EOF

		einfo PKG_CONFIG_PATH="${D}/${PC_DIRECTORY}" pkg-config --exists "${PC_FILENAME}"
		PKG_CONFIG_PATH="${D}/${PC_DIRECTORY}" pkg-config --exists "${PC_FILENAME}" || die ".pc file failed to validate."
		eend $?
	fi
}

# @FUNCTION: elib
# @DESCRIPTION: installs .dll file into filesystem
# $1 = path to install directory
# $2 = myassembly1 # path and filename with extension of the first .dll
# $3 = myassembly2 # path and filename with extension of the second .dll
# $N = myassemblyN-1 # other names
elib () {
	local INSTALL_PATH="$1" # $(library_assembly_dir)
	shift 1
	einfo "installing into ${INSTALL_PATH}"
	insinto "${INSTALL_PATH}"
	# https://unix.stackexchange.com/questions/128204/what-does-while-test-gt-0-do/128207
	while ${1+:} false ; do
		# https://stackoverflow.com/questions/2664740/extract-file-basename-without-path-and-extension-in-bash
		local ASSEMBLY_FILENAMEWEXT="${1##*/}"
		local ASSEMBLY_FILENAME="${ASSEMBLY_FILENAMEWEXT%.*}"
		einfo "ASSEMBLY_FILENAME=${ASSEMBLY_FILENAME}, ASSEMBLY_FILENAMEWEXT=${ASSEMBLY_FILENAMEWEXT}"
		einfo "doins \"$1\""
		doins "$1"
		einfo "elib: $1 is installed as ${INSTALL_PATH}/${ASSEMBLY_FILENAMEWEXT}"

		einstall_pc_file "${ASSEMBLY_FILENAME}" "${PV}" "${INSTALL_PATH}/${ASSEMBLY_FILENAMEWEXT}"

		shift
	done
	einfo "elib finished"
}
