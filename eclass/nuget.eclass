# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# @ECLASS: nuget.eclass
# @MAINTAINER: Heather@Cynede.net
# @BLURB: Common functionality for nuget apps
# @DESCRIPTION: Common functionality needed by fake build system.

inherit dotnet

# @ECLASS_VARIABLE: NUGET_DEPEND
# @DESCRIPTION Set false to net depend on nuget
: ${NUGET_NO_DEPEND:=}

if [[ -n $NUGET_NO_DEPEND ]]; then
	DEPEND+=" dev-dotnet/nuget"
fi

NPN=${PN/_/.}
if [[ $PV == *_alpha* ]]
then
	NPV=${PVR/_/-}
else
	NPV=${PVR}
fi

# @FUNCTION: nuget_src_unpack
# @DESCRIPTION: Runs nuget.
nuget_src_unpack() {
	nuget install "${NPN}" -Version "${NPV}" -OutputDirectory "${P}"
}

# @FUNCTION: nuget_src_configure
# @DESCRIPTION: Runs nothing.
nuget_src_configure() { :; }

# @FUNCTION: nuget_src_compile
# @DESCRIPTION: Runs nothing.
nuget_src_compile() { :; }

EXPORT_FUNCTIONS src_unpack src_configure src_compile
