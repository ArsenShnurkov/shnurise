# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: msbuild.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for working with msbuild command line utility
# @DESCRIPTION:
# This is the new replacement for xbuild eclass

inherit dotnet
inherit msbuild-framework

# the class "mono-pkg-config" is inherited to implement "doins.dll" function
# doins.dll installs .pc files, which are used during src_compile
inherit mono-pkg-config

# the class "gac" is inherited to implement "doins.dll" function
inherit gac

# the class "make_wrapper" is inherited to implement "doins.exe" function
# https://devmanual.gentoo.org/eclass-reference/wrapper.eclass/index.html
inherit wrapper

case ${EAPI:-0} in
	0) die "this eclass doesn't support EAPI 0" ;;
	1|2|3) ;;
	*) ;; #if [[ ${USE_MSBUILD} ]]; then REQUIRED_USE="|| (${USE_MSBUILD})"; fi;;
esac

DEPEND+=" dev-util/msbuild"

# Monodevelop-using applications need this to be set or they will try to create config
# files in the user's ~ dir.
export XDG_CONFIG_HOME="${T}"

# Building mono, nant and many other dotnet packages is known to fail if LC_ALL
# variable is not set to C. To prevent this all mono related packages will be
# build with LC_ALL=C (see bugs #146424, #149817)
export LC_ALL=C

# @FUNCTION: emsbuild_raw
# @DESCRIPTION: run msbuild with given parameters
emsbuild_raw() {
	elog """$@"""
	msbuild "$@" || die
}

# @FUNCTION: emsbuild
# @DESCRIPTION: run msbuild with Release of Debug configuration depending on USE="debug"
emsbuild() {
	if use debug; then
		CARGS=/p:Configuration=Debug
	else
		CARGS=/p:Configuration=Release
	fi

	if use developer; then
		SARGS=/p:DebugSymbols=True
	else
		SARGS=/p:DebugSymbols=False
	fi

	emsbuild_raw "${CARGS}" "${SARGS}" "$@"
}

msbuild_src_compile()
{
	emsbuild /p:BaseOutputPath="${T}"
}

# @FUNCTION: doins.dll
# @DESCRIPTION: installs an .dll file(s) and creates a wrapper for it
doins.dll()
{
	einfo called "doins.dll $@"
	elib $@
	einstall_pc_file "${PN}" "${PV}" $( get_destination_names $@ )
# should be done in pkg_postinst / pkg_prerm
#	egacinstall $@
}

# @FUNCTION: doins.exe
# @DESCRIPTION: installs an .exe file and creates a wrapper for it
doins.exe()
{
	einfo called "doins.exe $@"
}

EXPORT_FUNCTIONS src_compile
