# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: dotnet.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: common settings and functions for mono and dotnet related packages
# @DESCRIPTION:
# The dotnet eclass contains common environment settings that are useful for
# dotnet packages.  Currently, it 
# exports MONO_SHARED_DIR and
# sets LC_ALL in order to prevent errors during compilation of dotnet packages.

case ${EAPI:-0} in
	0|1|2|3|4|5|6) die "this eclass doesn't support EAPI-${EAPI:-0}" ;;
	*) ;; #if [[ ${USE_DOTNET} ]]; then REQUIRED_USE="|| (${USE_DOTNET})"; fi;;
esac

inherit eutils
inherit mono-env

# Building mono, nant and many other dotnet packages is known to fail if LC_ALL
# variable is not set to C. To prevent this all mono related packages will be
# build with LC_ALL=C (see bugs #146424, #149817)
export LC_ALL=C

# @FUNCTION: dotnet_multilib_comply
# @DESCRIPTION:  multilib comply
dotnet_multilib_comply() {
	use !prefix && has "${EAPI:-0}" 0 1 2 && ED="${D}"
	local dir finddirs=() mv_command=${mv_command:-mv}
	if [[ -d "${ED}/usr/lib" && "$(get_libdir)" != "lib" ]]
	then
		if ! [[ -d "${ED}"/usr/"$(get_libdir)" ]]
		then
			mkdir "${ED}"/usr/"$(get_libdir)" || die "Couldn't mkdir ${ED}/usr/$(get_libdir)"
		fi
		${mv_command} "${ED}"/usr/lib/* "${ED}"/usr/"$(get_libdir)"/ || die "Moving files into correct libdir failed"
		rm -rf "${ED}"/usr/lib
		for dir in "${ED}"/usr/"$(get_libdir)"/pkgconfig "${ED}"/usr/share/pkgconfig
		do

			if [[ -d "${dir}" && "$(find "${dir}" -name '*.pc')" != "" ]]
			then
				pushd "${dir}" &> /dev/null
				sed  -i -r -e 's:/(lib)([^a-zA-Z0-9]|$):/'"$(get_libdir)"'\2:g' \
					*.pc \
					|| die "Sedding some sense into pkgconfig files failed."
				popd "${dir}" &> /dev/null
			fi
		done
		if [[ -d "${ED}/usr/bin" ]]
		then
			for exe in "${ED}/usr/bin"/*
			do
				if [[ "$(file "${exe}")" == *"shell script text"* ]]
				then
					sed -r -i -e ":/lib(/|$): s:/lib(/|$):/$(get_libdir)\1:" \
						"${exe}" || die "Sedding some sense into ${exe} failed"
				fi
			done
		fi

	fi
}
