# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
inherit autotools dotnet

NAME="HtmlParserSharp"
HOMEPAGE="https://github.com/jamietre/${NAME}"

EGIT_COMMIT="2a450f49bb908d50461eae95dd4f74b872b5094e"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.zip -> ${PF}.zip"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

SLOT=0

DESCRIPTION="Validator.nu HTML Parser, a HTML5 parser, port from Java Version 1.4 to C#"
LICENSE="MPL" # https://github.com/jamietre/HtmlParserSharp/blob/master/LICENSE.txt
KEYWORDS="~amd64 ~x86"
IUSE=""

RDEPEND=">=dev-lang/mono-4.0.2.5"
DEPEND="${RDEPEND}
	sys-apps/sed"

S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"
SLN_FILE="${S}/${NAME}.sln"

src_unpack()
{
	# /usr/portage/distfiles/csquery-1.3.5.200.zip
	# /var/tmp/portage/dev-dotnet/csquery-1.3.5.200-r20150522/work/CsQuery-696ac0533a3e665a34cdc4050d1f46e91f5a3356
	default
}

src_prepare() {

	default

	nuget restore "${SLN_FILE}" || die
}

src_configure() {
	default
}

src_compile() {
	exbuild "${SLN_FILE}"
}

src_install() {
	default
}
