# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gentoo-net-sdk.eclass
# @MAINTAINER: cynede@gentoo.org
# @BLURB: replaces nuget to portage
# @DESCRIPTION:
# The dotnet eclass contains function eapply_gentoo_sdk

case ${EAPI:-0} in
	0|1|2|3|4|5|6) die "this eclass doesn't support EAPI-${EAPI:-0}" ;;
	*) ;; #if [[ ${USE_DOTNET} ]]; then REQUIRED_USE="|| (${USE_DOTNET})"; fi;;
esac

inherit dotnet msbuild

# @FUNCTION: dotnet_pkg_setup
# @DESCRIPTION: This function replaces Microsoft.NET.Sdk to Gentoo.NET.Sdk
gentoo-net-sdk_src_prepare() {
	einfo " -- REPLACING Microsoft.NET.Sdk into Gentoo.NET.Sdk -- "
	
	local varglobstar="$(shopt -p globstar)"
	einfo "Old value ${varglobstar}"
	shopt -s globstar
	for entry in "${S}"/**/*.csproj
	do
		einfo "Applying for ${entry}"
	    	eapply_gentoo_sdk "$entry"
	done
	${varglobstar} || die
	einfo "Restored as ${varglobstar}"

	default
}

eapply_gentoo_sdk() {
	einfo "TempDir = ${T}"
	local PATCHFILE="${T}/patch.proj"
	if [ ! -f "${PATCHFILE}" ]; then
		cat >"${PATCHFILE}" << '		EOF' || die
		<Project xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
			<Target Name="Build">
				<Message Text="Patching the project: $(Project)" />
				<XmlPoke
					XmlInputPath="$(Project)"
					Value="Gentoo.NET.Sdk"
					Query="/Project[@Sdk='Microsoft.NET.Sdk']/@Sdk[1]"
				/>
			</Target>
		</Project>
		EOF
	fi
	for var in "$@"
	do
		emsbuild ${T}/patch.proj -p:Project=${var}
	done
}

EXPORT_FUNCTIONS src_prepare
