# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

USE_DOTNET="net45"
IUSE="+${USE_DOTNET}"

inherit gac nupkg

SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/master/mono-4.5.2_p2016061606.tar.bz2"
S="${WORKDIR}/mono-4.5.2"

SLOT="0"

DESCRIPTION="A Getopt.Long-inspired option parsing library for CSharp"
HOMEPAGE="http://tirania.org/blog/archive/2008/Oct-14.html"
LICENSE="MIT"


CDEPEND=""
DEPEND="${CDEPEND}
	nupkg? ( dev-dotnet/nuget )
	"
RDEPEND="${CDEPEND}
	"

get_dlldir() {
	echo /usr/lib64/mono/mono-options
}

NUSPEC_VERSION=${PV}
ASSEMBLY_VERSION=${PV}

src_configure() {
	# dont' call default configure for the whole mono package, because it is slow
	cat <<-METADATA >AssemblyInfo.cs || die
			[assembly: System.Reflection.AssemblyVersion("${ASSEMBLY_VERSION}")]
		METADATA
}

src_compile() {
	# exbuild_strong "mcs/class/Mono.Options/Mono.Options-net_4_x.csproj" # csproj is created during configure
	if use gac; then
		PARAMETERS=-keyfile:mcs/class/mono.snk
	else
		PARAMETERS=
	fi
	mcs ${PARAMETERS} -r:System.Core mcs/class/Mono.Options/Mono.Options/Options.cs AssemblyInfo.cs -t:library -out:"Mono.Options.dll" || die "compilation failed"
	enuspec "${FILESDIR}/Mono.Options.nuspec"
}

src_install() {
	insinto "$(get_dlldir)/slot-${SLOT}"
	doins "Mono.Options.dll"

	dosym "slot-${SLOT}/Mono.Options.dll" "$(get_dlldir)/Mono.Options.dll"

	einstall_pc_file ${PN} ${ASSEMBLY_VERSION} Mono.Options

	enupkg "${WORKDIR}/Mono.Options.${NUSPEC_VERSION}.nupkg"
}

pkg_postinst() {
	if use gac; then
		einfo "adding to GAC"
		gacutil -i "$(get_dlldir)/slot-${SLOT}/Mono.Options.dll" || die
	fi
}

pkg_prerm() {
	if use gac; then
		# TODO determine version for uninstall from slot-N dir
		einfo "removing from GAC"
		gacutil -u Mono.Options
		# don't die, it there is no such assembly in GAC
	fi
}
