# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
KEYWORDS="amd64 arm64"
RESTRICT="mirror test"

SLOT="0"

USE_DOTNET="net45 net40 net35"
PATCHDIR="${FILESDIR}/2.2/"

inherit vcs-snapshot
inherit autotools 
# msbuild.eclass inherits dotnet itself
inherit msbuild
inherit systemd 

DESCRIPTION="XSP is a small web server that can host ASP.NET pages"
LICENSE="MIT"
HOMEPAGE="https://www.mono-project.com/docs/web/aspnet/"

EGIT_COMMIT="3330ff0790eaa48b0b54174edc0736b9b6006841"
SRC_URI="https://codeload.github.com/mono/xsp/tar.gz/${EGIT_COMMIT} -> ${PN}-${PV}.tar.gz"
# setting S is not necessary with vcs-snapshot
#S="${WORKDIR}/xsp-${EGIT_COMMIT}"

IUSE="+${USE_DOTNET} systemd openrc +xsp +modmono fastcgi examples doc test debug developer"
# systemd = install .service files
# openrc = install init.d scripts
# modmono = install mod-mono-server
# fastcgi = Add support for the FastCGI interface (install fastcgi-mono-server)
# man = Build the manpages
# examples = install test applications
# test ~= ??? unit tests ???

# RESTRICT is going below IUSE because of "test" USE flag (but I don't know is order important or no)"
RESTRICT="mirror  !test? ( test )"

DEPEND="dev-db/sqlite:3"
RDEPEND="
	${DEPEND}
	acct-group/aspnet
	acct-user/aspnet
"

SANDBOX_WRITE="${SANDBOX_WRITE}:/etc/mono/registry/:/etc/mono/registry/last-btime"

src_prepare() {
	eapply "${FILESDIR}/disable-tests.patch"
	eapply "${FILESDIR}/acme.patch"
	eapply "${FILESDIR}/aclocal-fix.patch"

	if [ -z "$LIBTOOL" ]; then
		LIBTOOL=`which glibtool 2>/dev/null`
		if [ ! -x "$LIBTOOL" ]; then
			LIBTOOL=`which libtool`
		fi
	fi
	eaclocal -I build/m4/shamrock -I build/m4/shave $ACLOCAL_FLAGS
	if test -z "$NO_LIBTOOLIZE"; then
		${LIBTOOL}ize --force --copy
	fi
	eapply_user
	eautoconf
	eautomake --gnu --add-missing --force --copy #nowarn
}

src_configure() {
	myeconfargs=("--enable-maintainer-mode")
	use test && myeconfargs+=("--with_unit_tests")
	( ! use doc ) || myeconfargs+=("--disable-docs")
	econf ${myeconfargs}
}

src_compile() {
	local PROPERTIES=(
		'/p:PrepareProjectReferencesDependsOn="AssignProjectConfiguration;_SplitProjectReferencesByFileExistence"'
		'/p:GetCopyToOutputDirectoryItemsDependsOn="AssignTargetPaths;_SplitProjectReferencesByFileExistence"'
	)
	# see https://unix.stackexchange.com/questions/29509/transform-an-array-into-arguments-of-a-command
	# ${PROPERTIES[@]}

	emsbuild ${PROPERTIES[@]} xsp.sln
}

#pkg_preinst() {
#	enewgroup aspnet
#	enewuser aspnet -1 -1 /tmp aspnet
#}

src_install() {
	emake DESTDIR="${ED}" install
	if test -z "$NO_LIBTOOLIZE"; then
		${LIBTOOL}ize --force --copy
	fi

	if ! use examples; then
		/bin/rm -rf "${ED}/usr/lib64/xsp/test" || die
	fi

	if use openrc; then
		if use xsp; then
			newinitd "${PATCHDIR}/xsp.initd" xsp
			newconfd "${PATCHDIR}/xsp.confd" xsp
		fi

		if use modmono; then
			newinitd "${PATCHDIR}/mod-mono-server-r1.initd" mod-mono-server
			newconfd "${PATCHDIR}/mod-mono-server.confd" mod-mono-server
		fi

		if use fastcgi; then
			newinitd "${PATCHDIR}/fastcgi-mono-server-r1.initd" fastcgi-mono-server
			newconfd "${PATCHDIR}/fastcgi-mono-server.confd" fastcgi-mono-server
		fi

		keepdir /var/run/aspnet
	fi

	if use systemd; then
		if use xsp; then
			keepdir "/etc/xsp4/conf.d"
			insinto "/etc/xsp4"
			doins "${FILESDIR}/systemd/mono.webapp"
			systemd_dounit "${FILESDIR}"/systemd/mono-xsp4.service
			if use doc; then
				insinto /etc/xsp4/conf.d
				doins "${FILESDIR}/systemd/readme.txt"
			fi
		fi

		if use modmono; then
			keepdir "/etc/mod-mono-server/conf.d"
			insinto "/etc/mod-mono-server"
			doins "${FILESDIR}/systemd/mono.webapp"
			systemd_dounit "${FILESDIR}"/systemd/mod-mono-server.service
			insinto "/etc/mod-mono-server"
			doins "${FILESDIR}/systemd/mono.webapp"
		fi

		if use fastcgi; then
			keepdir "/etc/fastcgi-mono-server/conf.d"
			insinto "/etc/fastcgi-mono-server"
			doins "${FILESDIR}/systemd/mono.webapp"
			systemd_dounit "${FILESDIR}"/systemd/fastcgi-mono-server.service
			insinto "/etc/fastcgi-mono-server"
			doins "${FILESDIR}/systemd/mono.webapp"
		fi
	fi
}
