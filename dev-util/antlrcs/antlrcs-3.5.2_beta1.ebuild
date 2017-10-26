# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

KEYWORDS="~amd64 ~ppc ~x86"
RESTRICT="mirror"

SLOT="0"

USE_DOTNET="net45"

inherit dotbuildtask

NAME="antlrcs"
HOMEPAGE="https://github.com/antlr/${NAME}"
EGIT_COMMIT="ca331b7109e1faa5a6aa7336bb6281ce9363e62b"
SRC_URI="https://github.com/ArsenShnurkov/shnurise-tarballs/raw/dev-utils/antlrcs/${PN}-${PV}.tar.gz -> ${NAME}-${PV}.tar.gz"
S="${WORKDIR}"

DESCRIPTION="The C# port of ANTLR 3"
LICENSE="BSD" # https://github.com/antlr/antlrcs/blob/master/LICENSE.txt

IUSE="+${USE_DOTNET} debug developer doc"

COMMON_DEPEND=">=dev-lang/mono-5.4.0.167 <dev-lang/mono-9999
"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
	dev-dotnet/antlr3-runtime
"

OUTPUT_PATH="artefacts"

src_prepare() {
	eapply_user
}

src_compile() {
	einfo "${S}/${OUTPUT_PATH}"
	mkdir -p "${OUTPUT_PATH}" || die

	FW_PATH="/usr/lib64/mono/4.6-api"

	COMMON_KEYS="/utf8output /subsystemversion:6.00 /noconfig /nowarn:1701,1702 /nostdlib+  /highentropyva+ /reference:${FW_PATH}/mscorlib.dll /reference:${FW_PATH}/System.dll /recurse:*.cs"
	if use debug; then
	COMMON_KEYS="${COMMON_KEYS} /define:DEBUG /debug+ /debug:full /optimize-"
	fi

	cd ${S}/Runtime/Antlr3.Runtime || die
	mono /usr/lib/mono/4.5/csc.exe /target:library "/out:${S}/${OUTPUT_PATH}/Antlr.Runtime.dll" /reference:${FW_PATH}/System.Core.dll ${COMMON_KEYS} || die

	cd ${S}/Runtime/Antlr3.Runtime.Debug || die
	mono /usr/lib/mono/4.5/csc.exe /target:library /out:${S}/${OUTPUT_PATH}/Antlr.Runtime.Debug.dll /reference:${FW_PATH}/System.Core.dll /reference:${S}/${OUTPUT_PATH}/Antlr.Runtime.dll ${COMMON_KEYS} || die

	cd ${S}/Antlr4.StringTemplate || die
	mono /usr/lib/mono/4.5/csc.exe /target:library /out:${S}/${OUTPUT_PATH}/Antlr4.StringTemplate.dll /reference:${FW_PATH}/System.Core.dll /reference:${S}/${OUTPUT_PATH}/Antlr.Runtime.dll ${COMMON_KEYS} || die

	cd ${S}/Antlr3 || die
	mono /usr/lib/mono/4.5/csc.exe /target:exe /out:${S}/${OUTPUT_PATH}/Antlr3.exe /define:NETSTANDARD /reference:${FW_PATH}/System.Core.dll /reference:${FW_PATH}/System.Xml.Linq.dll /reference:${S}/${OUTPUT_PATH}/Antlr.Runtime.dll /reference:${S}/${OUTPUT_PATH}/Antlr.Runtime.Debug.dll /reference:${S}/${OUTPUT_PATH}/Antlr4.StringTemplate.dll ${COMMON_KEYS} || die

	cd ${S}/Antlr3.Targets/Antlr3.Targets.CSharp3 || die
	mkdir -p ${S}/${OUTPUT_PATH}/Targets || die
	mono /usr/lib/mono/4.5/csc.exe /target:library /out:${S}/${OUTPUT_PATH}/Targets/Antlr3.Targets.CSharp3.dll /define:NETSTANDARD /reference:${FW_PATH}/System.Core.dll /reference:${S}/${OUTPUT_PATH}/Antlr3.exe /reference:${S}/${OUTPUT_PATH}/Antlr4.StringTemplate.dll ${COMMON_KEYS} || die
	cd ${S} || die
}

TASKS_PROPS_FILE="AntlrBuildTask/Antlr3.props"
TASKS_TARGETS_FILE="AntlrBuildTask/Antlr3.targets"

src_install() {
	einstask "${OUTPUT_PATH}/AntlrBuildTask.dll" "${S}/${TASKS_PROPS_FILE}" "${S}/${TASKS_TARGETS_FILE}"
}
