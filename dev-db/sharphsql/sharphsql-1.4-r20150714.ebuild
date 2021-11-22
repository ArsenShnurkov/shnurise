# Copyright 1999-2015 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"

inherit dotnet

DESCRIPTION="Small & embebdded database engine witten in C#, port of the Hypersonic SQL v1.4 (HSQL) Java project"

LICENSE="CDDL"   # LICENSE syntax is defined in https://wiki.gentoo.org/wiki/GLEP:23

SLOT="0"

IUSE="debug test gac nupkg"

PROJECTNAME="SharpHSQL"
HOMEPAGE="https://github.com/ArsenShnurkov/${PROJECTNAME}"
EGIT_COMMIT="cf0e0a369d35f0f43efa4b412d6f69fb33ae6261"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${P}-${PR}.zip"

KEYWORDS="~x86 ~amd64 ~ppc"
DEPEND="|| ( >=dev-lang/mono-3.12.0 <dev-lang/mono-9999 )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PROJECTNAME}-${EGIT_COMMIT}"

METAFILETOBUILD=src/${PROJECTNAME}.sln

src_compile() {
	# https://bugzilla.xamarin.com/show_bug.cgi?id=9340
	if use debug; then
		exbuild /p:DebugSymbols=True ${METAFILETOBUILD}
	else
		exbuild /p:DebugSymbols=False ${METAFILETOBUILD}
	fi
	if use nupkg; then
		elog "Building nuget package because USE=nupkg specified"
		elog "nuget pack ${FILESDIR}/SharpHSQL.csproj.nuspec -BasePath "${S}" -OutputDirectory ${WORKDIR} -NonInteractive -Verbosity detailed"
		nuget pack "${FILESDIR}/SharpHSQL.csproj.nuspec" -Properties Configuration=Release -BasePath "${S}" -OutputDirectory "${WORKDIR}" -NonInteractive -Verbosity detailed
	fi
}

src_install() {
	if use gac; then
		elog "Installing assemblies"
		egacinstall src/SharpHSQL/bin/Release/SharpHSQL.dll
#		doins src/SharpHSQL/bin/Release/*.mdb
	fi
	if use nupkg; then
		if [ -d "/var/calculate/remote/distfiles" ]; then
			# Control will enter here if the directory exist.
			# this is necessary to handle calculate linux profiles feature (for corporate users)
			elog "Installing .nupkg into /var/calculate/remote/packages/NuGet"
			insinto /var/calculate/remote/packages/NuGet
		else
			# this is for all normal gentoo-based distributions
			elog "Installing .nupkg into /usr/local/nuget/nupkg"
			insinto /usr/local/nuget/nupkg
		fi
		doins "${WORKDIR}/SharpHSQL.1.0.3.nupkg"
	fi
}
