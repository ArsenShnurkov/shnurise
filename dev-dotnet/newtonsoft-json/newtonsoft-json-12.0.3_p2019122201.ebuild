# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

SLOT="0"

# pkg-config = register in pkg-config database
# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# source = install source files for source-level debugging
USE_DOTNET="net45"
IUSE="${USE_DOTNET} +pkg-config debug developer source"

inherit dotnet mono-pkg-config

HOMEPAGE="https://github.com/JamesNK/Newtonsoft.Json"

EGIT_COMMIT="a31156e90a14038872f54eb60ff0e9676ca4a0d8"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz"
NAME="Newtonsoft.Json"
S="${WORKDIR}/${NAME}-${EGIT_COMMIT}"

DESCRIPTION="Json.NET is a popular high-performance JSON framework for .NET"
LICENSE="MIT"
LICENSE_URL="https://raw.github.com/JamesNK/Newtonsoft.Json/master/LICENSE.md"

COMMON_DEPEND="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPEND}
"
DEPEND="${COMMON_DEPEND}
"

function bin_dir ( ) {
	echo "${WORKDIR}/$(output_relpath)"
}

function references1() {
	echo -n " " /reference:System.dll
	echo -n " " /reference:System.Numerics.dll
}

function defines1() {
	echo -n " -define:HAVE_ADO_NET;HAVE_APP_DOMAIN;HAVE_ASYNC;HAVE_BIG_INTEGER;HAVE_BINARY_FORMATTER;HAVE_BINARY_SERIALIZATION;HAVE_BINARY_EXCEPTION_SERIALIZATION;HAVE_CAS;HAVE_CHAR_TO_LOWER_WITH_CULTURE;HAVE_CHAR_TO_STRING_WITH_CULTURE;HAVE_COM_ATTRIBUTES;HAVE_COMPONENT_MODEL;HAVE_CONCURRENT_COLLECTIONS;HAVE_COVARIANT_GENERICS;HAVE_DATA_CONTRACTS;HAVE_DATE_TIME_OFFSET;HAVE_DB_NULL_TYPE_CODE;HAVE_DYNAMIC;HAVE_EMPTY_TYPES;HAVE_ENTITY_FRAMEWORK;HAVE_EXPRESSIONS;HAVE_FAST_REVERSE;HAVE_FSHARP_TYPES;HAVE_FULL_REFLECTION;HAVE_GUID_TRY_PARSE;HAVE_HASH_SET;HAVE_ICLONEABLE;HAVE_ICONVERTIBLE;HAVE_IGNORE_DATA_MEMBER_ATTRIBUTE;HAVE_INOTIFY_COLLECTION_CHANGED;HAVE_INOTIFY_PROPERTY_CHANGING;HAVE_ISET;HAVE_LINQ;HAVE_MEMORY_BARRIER;HAVE_METHOD_IMPL_ATTRIBUTE;HAVE_NON_SERIALIZED_ATTRIBUTE;HAVE_READ_ONLY_COLLECTIONS;HAVE_REFLECTION_EMIT;HAVE_SECURITY_SAFE_CRITICAL_ATTRIBUTE;HAVE_SERIALIZATION_BINDER_BIND_TO_NAME;HAVE_STREAM_READER_WRITER_CLOSE;HAVE_STRING_JOIN_WITH_ENUMERABLE;HAVE_TIME_SPAN_PARSE_WITH_CULTURE;HAVE_TIME_SPAN_TO_STRING_WITH_CULTURE;HAVE_TIME_ZONE_INFO;HAVE_TRACE_WRITER;HAVE_TYPE_DESCRIPTOR;HAVE_UNICODE_SURROGATE_DETECTION;HAVE_VARIANT_TYPE_PARAMETERS;HAVE_VERSION_TRY_PARSE;HAVE_XLINQ;HAVE_XML_DOCUMENT;HAVE_XML_DOCUMENT_TYPE;HAVE_CONCURRENT_DICTIONARY;"
}

function sources1() {
	echo -n " " $(csharp_sources "${S}/Src/Newtonsoft.Json")
}

SRC_INSTALL_DIR=/usr/src/${CATEGORY}/${PN}-${PV}

function output_arguments1 ( ) {
	#output type and name
	local OUTPUT_TYPE="library" # https://docs.microsoft.com/ru-ru/dotnet/csharp/language-reference/compiler-options/target-exe-compiler-option
	echo  "/target:${OUTPUT_TYPE}" "/out:$(output_filename1)"

	# for reproducible builds
	echo -n " " -deterministic

	# debug information options
	if use debug; then
		echo -n " " /debug:full
	fi

	# create .pdb file
	if use developer; then
		echo -n " " /pdb:$(bin_dir)/${NAME}.pdb
	fi

	# path for sources
	if use source; then
		# options for source-level debugging
		echo -n " " /pathmap:path1=${S},path2=${SRC_INSTALL_DIR}
	fi
}

function output_filename1( ) {
	echo "$(bin_dir)/${NAME}.dll"
}

src_prepare() {
	eapply_user
}

src_compile() {
	mkdir -p $(bin_dir) || die
	einfo /usr/bin/csc $(references1) $(sources1) $(output_arguments1)
	/usr/bin/csc $(references1) $(defines1) $(sources1) $(output_arguments1) || die
}

src_install() {
	#insinto "$(get_nuget_trusted_icons_location)"
	#einstall_pc_file "${PN}" "8.0" "${NAME}"
	:;
}
