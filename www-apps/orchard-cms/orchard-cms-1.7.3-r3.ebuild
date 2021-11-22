# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="173"

USE_DOTNET="net45"
IUSE="${USE_DOTNET} vhosts"

inherit mpt-r20150903 xbuild

GITHUB_ACCOUNT_NAME="OrchardCMS"
GITHUB_REPOSITORY_NAME="Orchard"
EGIT_COMMIT="e737aa08ec3068a8e4f6057550e6df3d0884cabf"
SRC_URI="https://github.com/${GITHUB_ACCOUNT_NAME}/${GITHUB_REPOSITORY_NAME}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz"

S="${WORKDIR}/${GITHUB_REPOSITORY_NAME}-${EGIT_COMMIT}"

LICENSE="BSD"
DESCRIPTION="CMS written with CSharp"
HOMEPAGE="http://www.orchardproject.net/"

CDEPEND="
	dev-dotnet/autofac:2
	dev-dotnet/autofac-configuration:2
	dev-dotnet/castle-core:1
	dev-dotnet/castle-dynamicproxy
	>=dev-dotnet/log4net-1.2.11-r2
	dev-dotnet/nhibernate-linq
	dev-dotnet/fluent-nhibernate
	www-apache/mod_mono
"
DEPEND="${CDEPEND}
	dev-util/nunit2
"
RDEPEND="${CDEPEND}
"

src_prepare() {
	# remove untrusted binary files
	rm -rf "${S}/lib" || die

	# patch remaining source code
	epatch "${FILESDIR}/SqlAzure.patch"
	epatch "${FILESDIR}/case-of-path-letters.patch"
	epatch "${FILESDIR}/web-config.patch"
	eapply "${FILESDIR}/add-reference-to-system-data-${PV}.patch"
	empt-csproj --replace-reference="Castle.Core" --package-hintpath="/usr/share/dev-dotnet/castle-core-1/Castle.Core.dll" "${S}"
	eapply_user
}

src_compile() {
	local CONFIGURATION=""
	if use debug; then
		CONFIGURATION="Debug"
	else
		CONFIGURATION="Release"
	fi
	exbuild /p:TargetFrameworkVersion=v4.5 "/p:Configuration=${CONFIGURATION}" "${S}/src/Orchard.sln"
}

src_install() {
	# see https://wiki.gentoo.org/wiki/GLEP:11#Installation_Paths
	dodir /usr/share/webapps/${PF}/htdocs/
	dodir /usr/share/webapps/${PF}/htdocs/App_Data
	dodir /usr/share/webapps/${PF}/htdocs/App_Data/Dependencies
	#insinto /usr/share/webapps/${PF}/htdocs/
	# http://askubuntu.com/questions/86822/how-can-i-copy-the-contents-of-a-folder-to-another-folder-in-a-different-directo
	cp -a "${S}/src/Orchard.Web/." "${D}/usr/share/webapps/${PF}/htdocs/" || die
	chown -R aspnet:aspnet "${D}/usr/share/webapps/${PF}/htdocs" || die
}
