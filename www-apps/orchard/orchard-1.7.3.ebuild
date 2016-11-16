# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
KEYWORDS="~amd64 ~x86"

USE_DOTNET="net45"
inherit dotnet

IUSE="vhosts"

SRC_URI="http://download-codeplex.sec.s-msft.com/Download/Release?ProjectName=orchard&DownloadId=820579&FileTime=130405900542070000&Build=21031 -> ${PN}-${PV}.zip"
RESTRICT="mirror"

S="${WORKDIR}"

LICENSE="BSD"
DESCRIPTION="CMS written with CSharp"
HOMEPAGE="http://www.orchardproject.net/"

SLOT="1.7.3"

CDEPEND="
	>=dev-lang/mono-4.9.0.729-r1
	www-apache/mod_mono
	dev-dotnet/castle-core
	dev-dotnet/autofac
	dev-dotnet/autofac-configuration
"
DEPEND="${CDEPEND}"
RDEPEND="${CDEPEND}"

src_prepare() {
	# remove untrusted binary files
	rm -rf "${S}/lib" || die

	# patch remaining source code
	epatch "${FILESDIR}/case-of-path-letters.patch"
	epatch "${FILESDIR}/web-config.patch"
	eapply "${FILESDIR}/add-reference-to-system-data-${PV}.patch"
	eapply_user
}

src_compile() {
	exbuild "${S}/src/Orchard.sln"
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
