# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="8"

KEYWORDS="amd64 ~arm64"
SLOT="0"
RESTRICT="mirror test"

USE_DOTNET="net45"

# debug = debug configuration (symbols and defines for debugging)
# developer = generate symbols information (to view line numbers in stack traces, either in debug or release configuration)
# test = allow NUnit tests to run
# nupkg = create .nupkg file from .nuspec
# gac = install into gac
# pkg-config = register in pkg-config database
IUSE="${USE_DOTNET} debug developer +gac pkg-config nupkg test"

inherit vcs-snapshot
inherit mono-pkg-config
inherit dotnet

NAME="Newtonsoft.Json"
HOMEPAGE="https://github.com/JamesNK/Newtonsoft.Json"

EGIT_COMMIT="0a2e291c0d9c0c7675d445703e51750363a549ef"
SRC_URI="${HOMEPAGE}/archive/${EGIT_COMMIT}.tar.gz -> ${CATEGORY}-${PN}-${PV}.tar.gz"
S="${WORKDIR}/${CATEGORY}-${PN}-${PV}"

DESCRIPTION="Json.NET is a popular high-performance JSON framework for .NET"
LICENSE="MIT"
LICENSE_URL="https://raw.github.com/JamesNK/Newtonsoft.Json/master/LICENSE.md"

COMMON_DEPENDENCIES="|| ( >=dev-lang/mono-4.2 <dev-lang/mono-9999 )"
RDEPEND="${COMMON_DEPENDENCIES}
"
DEPEND="${COMMON_DEPENDENCIES}
"

final_dll() {
	echo "$(bin_dir)/Newtonsoft.Json.dll"
}

function define_constants () {
	echo -n \
		" -d:HAVE_ADO_NET" \
		" -d:HAVE_APP_DOMAIN" \
		" -d:HAVE_ASYNC" \
		" -d:HAVE_BIG_INTEGER" \
		" -d:HAVE_BINARY_FORMATTER" \
		" -d:HAVE_BINARY_SERIALIZATION" \
		" -d:HAVE_BINARY_EXCEPTION_SERIALIZATION" \
		" -d:HAVE_CAS" \
		" -d:HAVE_CHAR_TO_LOWER_WITH_CULTURE" \
		" -d:HAVE_CHAR_TO_STRING_WITH_CULTURE" \
		" -d:HAVE_COM_ATTRIBUTES" \
		" -d:HAVE_COMPONENT_MODEL" \
		" -d:HAVE_CONCURRENT_COLLECTIONS" \
		" -d:HAVE_COVARIANT_GENERICS" \
		" -d:HAVE_DATA_CONTRACTS" \
		" -d:HAVE_DATE_TIME_OFFSET" \
		" -d:HAVE_DB_NULL_TYPE_CODE" \
		" -d:HAVE_DYNAMIC" \
		" -d:HAVE_EMPTY_TYPES" \
		" -d:HAVE_ENTITY_FRAMEWORK" \
		" -d:HAVE_EXPRESSIONS" \
		" -d:HAVE_FAST_REVERSE" \
		" -d:HAVE_FSHARP_TYPES" \
		" -d:HAVE_FULL_REFLECTION" \
		" -d:HAVE_GUID_TRY_PARSE" \
		" -d:HAVE_HASH_SET" \
		" -d:HAVE_ICLONEABLE" \
		" -d:HAVE_ICONVERTIBLE" \
		" -d:HAVE_IGNORE_DATA_MEMBER_ATTRIBUTE" \
		" -d:HAVE_INOTIFY_COLLECTION_CHANGED" \
		" -d:HAVE_INOTIFY_PROPERTY_CHANGING" \
		" -d:HAVE_ISET;HAVE_LINQ" \
		" -d:HAVE_MEMORY_BARRIER" \
		" -d:HAVE_METHOD_IMPL_ATTRIBUTE" \
		" -d:HAVE_NON_SERIALIZED_ATTRIBUTE" \
		" -d:HAVE_READ_ONLY_COLLECTIONS" \
		" -d:HAVE_REFLECTION_EMIT" \
		" -d:HAVE_REGEX_TIMEOUTS" \
		" -d:HAVE_SECURITY_SAFE_CRITICAL_ATTRIBUTE" \
		" -d:HAVE_SERIALIZATION_BINDER_BIND_TO_NAME" \
		" -d:HAVE_STREAM_READER_WRITER_CLOSE" \
		" -d:HAVE_STRING_JOIN_WITH_ENUMERABLE" \
		" -d:HAVE_TIME_SPAN_PARSE_WITH_CULTURE" \
		" -d:HAVE_TIME_SPAN_TO_STRING_WITH_CULTURE" \
		" -d:HAVE_TIME_ZONE_INFO" \
		" -d:HAVE_TRACE_WRITER" \
		" -d:HAVE_TYPE_DESCRIPTOR" \
		" -d:HAVE_UNICODE_SURROGATE_DETECTION" \
		" -d:HAVE_VARIANT_TYPE_PARAMETERS" \
		" -d:HAVE_VERSION_TRY_PARSE" \
		" -d:HAVE_XLINQ" \
		" -d:HAVE_XML_DOCUMENT" \
		" -d:HAVE_XML_DOCUMENT_TYPE" \
		" -d:HAVE_CONCURRENT_DICTIONARY" \
		" "
}

function references () {
	echo -n \
		$(reference_framework System.Numerics) \
		$(reference_framework System)
}

src_prepare() {
	eapply_user
}

src_compile() {
	mkdir -p "$(bin_dir)" || die
	ecsc $(references) $(define_constants) $(csharp_sources Src/Newtonsoft.Json) $(output_dll Newtonsoft.Json)
}

src_install() {
	elib2  "$(anycpu_current_assembly_dir)" "$(final_dll)"
}
