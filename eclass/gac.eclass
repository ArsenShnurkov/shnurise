# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gac.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: functions for registring in gac
# @DESCRIPTION:
# binary packages should be able to be registred in gac too

case ${EAPI:-0} in
	0|1|2|3|4|5) die "this eclass doesn't support EAPI ${EAPI:-0}" ;;
	6) ;;
esac

IUSE+=" gac pkg-config"

DEPEND+=" dev-lang/mono"
RDEPEND+=" dev-lang/mono"

# SRC_URI+=" https://github.com/mono/mono/raw/master/mcs/class/mono.snk"
# I was unable to setup it this ^^ way
# So this is how it should look like:
#SRC_URI="...
#	mskey? ( https://github.com/Microsoft/msbuild/raw/master/src/MSFT.snk )
#	https://github.com/mono/mono/raw/master/mcs/class/mono.snk
#	"

# @FUNCTION: gac_root
# @DESCRIPTION:  returns location of GAC directory root
function gac_root {
#	echo /usr/$(get_libdir)
	echo /usr/lib
}

# @FUNCTION: gac_dir
# @DESCRIPTION:  returns location of GAC directory
function gac_dir {
	echo $(gac_root)/mono/gac
}

# @FUNCTION: token
# @DESCRIPTION:  returns Microsoft's PublicKeyToken or mono's one depending on USE="mskey"
function token {
	if use mskey; then
		echo "b03f5f7f11d50a3a"
	else
		echo "0738eb9f132ed756"
	fi
}

# @FUNCTION: signing_key
# @DESCRIPTION:  returns the location of mono.snk for signing
function signing_key {
	echo "${DISTDIR}/mono.snk"
}

# @FUNCTION: token_key
# @DESCRIPTION:  returns the location of MSFT.snk or mono.snk for making token depending on USE="mskey"
function token_key {
	if use mskey; then
		echo "${DISTDIR}/MSFT.snk"
	else
		echo "$(signing_key)"
	fi
}

# @FUNCTION: egacinstall
# @DESCRIPTION:  install package to GAC
egacinstall() {
	use !prefix && has "${EAPI:-0}" 0 1 2 && ED="${D}"
	if use gac; then
		if use pkg-config; then
			gacutil -i "${1}" \
				-root "${ED}"$(gac_root) \
				-gacdir $(gac_dir) \
				-package ${2:-${GACPN:-${PN}}} \
				|| die "installing ${1} into the Global Assembly Cache failed"
		else
			gacutil -i "${1}" \
				-root "${ED}"$(gac_root) \
				-gacdir $(gac_dir) \
				|| die "installing ${1} into the Global Assembly Cache failed"
		fi
	fi
}

# @FUNCTION: egac
# @DESCRIPTION:  stub for future replacement of egacinstall with the impmenetation, which uses egacadd and egacdell
egac() {
	if use gac; then
		egacinstall $@
	fi
}

# @FUNCTION: egacadd
# @DESCRIPTION:  install package to GAC
egacadd() {
	if use gac; then
		einfo gacutil -i "${PREFIX}/${1}" -root "$(gac_root)" -gacdir "$(gac_dir)"
		gacutil -i "${PREFIX}/${1}" \
			-root $(gac_root) \
			-gacdir $(gac_dir) \
			|| die "installing ${1} into the Global Assembly Cache failed"
	fi
}

# @FUNCTION: egacdel
# @DESCRIPTION:  remove package from GAC
egacdel() {
	if use gac; then
		einfo gacutil -u "${1}" -root "${GACROOT}" -gacdir "${GACDIR}"
		gacutil -u "${1}" \
			-root $(gac_root) \
			-gacdir $(gac_dir) 
		# don't die
	fi
}
