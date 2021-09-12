# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"
RESTRICT="mirror"
KEYWORDS="amd64 arm64"

SLOT="$(ver_cut 1-2 ${PV})"
SLOT_OF_API="${SLOT}" # slot for ebuild with API of msbuild

VER="${SLOT_OF_API}.0.0" # version of resulting .dll files in GAC

USE_DOTNET="net46"
IUSE="+${USE_DOTNET} +gac +mskey debug developer"
MSBUILD_TARGET="msbuild${SLOT/./-}"

# msbuild-framework.eclass is inherited to get the access to the locations 
# $(MSBuildBinPath) and $(MSBuildSdksPath)
inherit msbuild-framework xbuild gac

GITHUB_ACCOUNT="Microsoft"
GITHUB_PROJECTNAME="msbuild"
EGIT_COMMIT="88f5fadfbef809b7ed2689f72319b7d91792460e"
SRC_URI="https://github.com/${GITHUB_ACCOUNT}/${GITHUB_PROJECTNAME}/archive/${EGIT_COMMIT}.tar.gz -> ${GITHUB_PROJECTNAME}-${GITHUB_ACCOUNT}-${PV}.tar.gz"
S="${WORKDIR}/${GITHUB_PROJECTNAME}-${EGIT_COMMIT}"

HOMEPAGE="https://github.com/Microsoft/msbuild"
DESCRIPTION="default tasks for Microsoft Build Engine (MSBuild)"
LICENSE="MIT" # https://github.com/Microsoft/msbuild/blob/master/LICENSE

COMMON_DEPEND=">=dev-lang/mono-5.2.0.196
	dev-dotnet/msbuild-tasks-api:${SLOT_OF_API}[pkg-config] developer? ( dev-dotnet/msbuild-tasks-api:${SLOT_OF_API}[pkg-config,developer] )
	dev-dotnet/system-collections-immutable[pkg-config] developer? ( dev-dotnet/system-collections-immutable[pkg-config,developer] )
	dev-dotnet/system-reflection-metadata[pkg-config] developer? ( dev-dotnet/system-reflection-metadata[pkg-config,developer] )
"
RDEPEND="${COMMON_DEPEND}
"

# Commented out
# DEPEND=
#	dev-dotnet/buildtools

DEPEND="${COMMON_DEPEND}
	>=dev-dotnet/msbuildtasks-1.5.0.240-r1
"

PROJ=Microsoft.Build.Tasks.Core
PROJ_DIR=src/Tasks

function output_filename ( ) {
	echo "${S}/${PROJ_DIR}/bin/$(usedebug_tostring)/${PROJ}.dll"
}

src_prepare() {
	cp "${FILESDIR}/AV.cs" "${S}/${PROJ_DIR}" || die
	eapply_user
}

DEFINES=(
FEATURE_64BIT_ENVIRONMENT_QUERY
FEATURE_APARTMENT_STATE
FEATURE_APM
FEATURE_APPDOMAIN
FEATURE_APPDOMAIN_UNHANDLED_EXCEPTION
FEATURE_ASPNET_COMPILER
FEATURE_ASSEMBLYNAME_CLONE
FEATURE_ASSEMBLY_GETENTRYASSEMBLY
FEATURE_ASSEMBLY_LOADFROM
FEATURE_ASSEMBLY_LOCATION
FEATURE_BINARY_SERIALIZATION
FEATURE_CHARSET_AUTO
FEATURE_CODEDOM
FEATURE_CODETASKFACTORY
FEATURE_COM_INTEROP
FEATURE_CONSOLE_BUFFERWIDTH
FEATURE_CONSTRAINED_EXECUTION
FEATURE_CULTUREINFO_CONSOLE_FALLBACK
FEATURE_CULTUREINFO_GETCULTUREINFO
FEATURE_CULTUREINFO_GETCULTURES
FEATURE_DEBUGGER
FEATURE_DOTNETVERSION
FEATURE_ENVIRONMENT_SYSTEMDIRECTORY
FEATURE_FUSION_COMPAREASSEMBLYIDENTITY
FEATURE_GET_COMMANDLINE
FEATURE_HANDLEPROCESSCORRUPTEDSTATEEXCEPTIONS
FEATURE_HANDLEREF
FEATURE_HANDLE_SAFEWAITHANDLE
FEATURE_HTTP_LISTENER
FEATURE_MEMORYSTREAM_GETBUFFER
FEATURE_MSCOREE
FEATURE_MULTIPLE_TOOLSETS
FEATURE_NAMED_PIPES_FULL_DUPLEX
FEATURE_NAMED_PIPE_SECURITY_CONSTRUCTOR
FEATURE_OSVERSION
FEATURE_PERFORMANCE_COUNTERS
FEATURE_PFX_SIGNING
FEATURE_PIPE_SECURITY
FEATURE_REFLECTION_EMIT_DEBUG_INFO
FEATURE_RESGEN
FEATURE_RESGENCACHE
FEATURE_RESOURCEMANAGER_GETRESOURCESET
FEATURE_RESOURCE_EXPOSURE
FEATURE_RESX_RESOURCE_READER
FEATURE_RUNTIMEINFORMATION
FEATURE_RUN_EXE_IN_TESTS
FEATURE_SECURITY_PRINCIPAL_WINDOWS
FEATURE_STRING_INTERN
FEATURE_STRONG_NAMES
FEATURE_SYSTEMPAGESIZE
FEATURE_SYSTEM_CONFIGURATION
FEATURE_TASKHOST
FEATURE_TASK_GENERATERESOURCES
FEATURE_THREAD_ABORT
FEATURE_THREAD_CULTURE
FEATURE_THREAD_PRIORITY
FEATURE_TYPE_GETCONSTRUCTOR
FEATURE_TYPE_GETINTERFACE
FEATURE_TYPE_INVOKEMEMBER
FEATURE_USERDOMAINNAME
FEATURE_USERINTERACTIVE
FEATURE_VARIOUS_EXCEPTIONS
FEATURE_WORKINGSET
FEATURE_XML_LOADPATH
FEATURE_XML_SOURCE_URI
MICROSOFT_BUILD_TASKS
STANDALONEBUILD
USE_MSBUILD_DLL_EXTN
)
#FEATURE_XAMLTASKFACTORY
#FEATURE_XAML_TYPES

SOURCE_FILES=(
AV.cs
../MSBuildTaskHost/Concurrent/ConcurrentDictionary.cs
../MSBuildTaskHost/Concurrent/ConcurrentQueue.cs
../MSBuildTaskHost/FileSystem/MSBuildTaskHostFileSystem.cs
../Shared/ReuseableStringBuilder.cs
../Shared/EnvironmentUtilities.cs
../Shared/AssemblyFolders/AssemblyFoldersEx.cs
../Shared/AssemblyFolders/AssemblyFoldersFromConfig.cs
../Shared/AssemblyFolders/Serialization/AssemblyFolderCollection.cs
../Shared/AssemblyFolders/Serialization/AssemblyFolderItem.cs
../Shared/BuildEnvironmentHelper.cs
../Shared/FxCopExclusions/Microsoft.Build.Shared.Suppressions.cs
../Shared/AssemblyNameComparer.cs
../Shared/AssemblyNameReverseVersionComparer.cs
../Shared/CanonicalError.cs
../Shared/Constants.cs
AssemblyDependency/AssemblyMetadata.cs
ConvertToAbsolutePath.cs
../Shared/CopyOnWriteDictionary.cs
../Shared/ExtensionFoldersRegistryKey.cs
../Shared/FileDelegates.cs
../Shared/HybridDictionary.cs
../Shared/NativeMethodsShared.cs
../Shared/AssemblyUtilities.cs
../Shared/NGen.cs
../Shared/OpportunisticIntern.cs
../Shared/PropertyParser.cs
../Shared/ReadOnlyEmptyCollection.cs
../Shared/RegistryDelegates.cs
../Shared/RegistryHelper.cs
../Shared/StringBuilderCache.cs
../Shared/StrongNameHelpers.cs
../Shared/TaskLoggingHelperExtension.cs
../Shared/TempFileUtilities.cs
../Shared/MetadataConversionUtilities.cs
../Shared/LanguageParser/StreamMappedString.cs
../Shared/ExceptionHandling.cs
../Shared/FileUtilities.cs
../Shared/EscapingUtilities.cs
../Shared/FileMatcher.cs
../Shared/Modifiers.cs
../Shared/ReadOnlyCollection.cs
../Shared/ReadOnlyEmptyDictionary.cs
../Shared/Tracing.cs
../Shared/Traits.cs
../Shared/VersionUtilities.cs
../Shared/VisualStudioConstants.cs
../Shared/VisualStudioLocationHelper.cs
../Shared/AssemblyNameExtension.cs
../Shared/EncodingUtilities.cs
../Shared/ErrorUtilities.cs
../Shared/ConversionUtilities.cs
../Shared/FileUtilitiesRegex.cs
../Shared/InternalErrorException.cs
../Shared/ResourceUtilities.cs
../Shared/LanguageParser/token.cs
../Shared/LanguageParser/tokenChar.cs
../Shared/LanguageParser/tokenCharReader.cs
../Shared/LanguageParser/tokenEnumerator.cs
../Shared/LanguageParser/CSharptokenCharReader.cs
../Shared/LanguageParser/CSharptokenEnumerator.cs
../Shared/LanguageParser/CSharptokenizer.cs
../Shared/LanguageParser/VisualBasictokenCharReader.cs
../Shared/LanguageParser/VisualBasictokenEnumerator.cs
../Shared/LanguageParser/VisualBasictokenizer.cs
AssemblyDependency/AssemblyFoldersExResolver.cs
AssemblyDependency/AssemblyFoldersFromConfig/AssemblyFoldersFromConfigCache.cs
AssemblyDependency/AssemblyFoldersFromConfig/AssemblyFoldersFromConfigResolver.cs
AssemblyDependency/AssemblyFoldersResolver.cs
AssemblyDependency/AssemblyInformation.cs
AssemblyDependency/AssemblyNameReference.cs
AssemblyDependency/AssemblyNameReferenceAscendingVersionComparer.cs
AssemblyDependency/AssemblyResolution.cs
AssemblyDependency/AssemblyResolutionConstants.cs
AssemblyDependency/BadImageReferenceException.cs
AssemblyDependency/CandidateAssemblyFilesResolver.cs
AssemblyDependency/ConflictLossReason.cs
AssemblyDependency/CopyLocalState.cs
AssemblyDependency/DependencyResolutionException.cs
AssemblyDependency/DirectoryResolver.cs
AssemblyDependency/DisposableBase.cs
AssemblyDependency/FrameworkPathResolver.cs
AssemblyDependency/GenerateBindingRedirects.cs
AssemblyDependency/HintPathResolver.cs
AssemblyDependency/InstalledAssemblies.cs
AssemblyDependency/InvalidReferenceAssemblyNameException.cs
AssemblyDependency/NoMatchReason.cs
AssemblyDependency/RawFilenameResolver.cs
AssemblyDependency/Reference.cs
AssemblyDependency/ReferenceResolutionException.cs
AssemblyDependency/ReferenceTable.cs
AssemblyDependency/ResolutionSearchLocation.cs
AssemblyDependency/Resolver.cs
AssemblyDependency/ResolveAssemblyReference.cs
AssemblyDependency/TaskItemSpecFilenameComparer.cs
AssemblyDependency/UnificationReason.cs
AssemblyDependency/UnificationVersion.cs
AssemblyDependency/UnifiedAssemblyName.cs
AssemblyDependency/WarnOrErrorOnTargetArchitectureMismatchBehavior.cs
AssemblyFolder.cs
AssemblyInfo.cs
AssemblyRemapping.cs
AssemblyResources.cs
AssignLinkMetadata.cs
AssignProjectConfiguration.cs
AssignTargetPath.cs
CallTarget.cs
CombinePath.cs
CommandLineBuilderExtension.cs
BuildCacheDisposeWrapper.cs
FileState.cs
Copy.cs
CreateCSharpManifestResourceName.cs
CreateVisualBasicManifestResourceName.cs
CreateItem.cs
CreateManifestResourceName.cs
CreateProperty.cs
CSharpParserUtilities.cs
Delegate.cs
Delete.cs
Error.cs
Exec.cs
FindAppConfigFile.cs
GetFrameworkPath.cs
GetReferenceAssemblyPaths.cs
Hash.cs
InstalledSDKResolver.cs
ErrorFromResources.cs
ExtractedClassName.cs
FileIO/ReadLinesFromFile.cs
FileIO/WriteLinesToFile.cs
FindInList.cs
FormatVersion.cs
FxCopExclusions/Microsoft.Build.Tasks.Suppressions.cs
ResGenDependencies.cs
ResGen.cs
GenerateResource.cs
IAnalyzerHostObject.cs
ICscHostObject.cs
ICscHostObject2.cs
ICscHostObject3.cs
ICscHostObject4.cs
IVbcHostObject.cs
IVbcHostObject2.cs
IVbcHostObject3.cs
IVbcHostObject4.cs
IVbcHostObject5.cs
IVbcHostObjectFreeThreaded.cs
InvalidParameterValueException.cs
ListOperators/FindUnderPath.cs
ListOperators/RemoveDuplicates.cs
LockCheck.cs
MakeDir.cs
Message.cs
Move.cs
MSBuild.cs
NativeMethods.cs
ParserState.cs
RedistList.cs
RemoveDir.cs
ResolveCodeAnalysisRuleSet.cs
ResolveKeySource.cs
ResolveProjectBase.cs
TaskExtension.cs
Telemetry.cs
ToolTaskExtension.cs
Touch.cs
VisualBasicParserUtilities.cs
Warning.cs
AssignCulture.cs
Culture.cs
CultureInfoCache.cs
WriteCodeFragment.cs
XmlPeek.cs
XmlPoke.cs
CodeTaskFactory.cs
StateFileBase.cs
Dependencies.cs
SystemState.cs
DependencyFile.cs
ZipDirectory.cs
Interop.cs
SdkToolsPathUtility.cs
system.design/stronglytypedresourcebuilder.cs
)
#XamlTaskFactory/XamlTaskFactory.cs

references() {
# error CS0006: Metadata file 'System.Runtime.dll' could not be found
#     ValueType
# error CS0006: Metadata file 'System.Collections.Concurrent.dll' could not be found
# error CS0006: Metadata file 'System.Runtime.InteropServices.RuntimeInformation.dll' could not be found
# error CS0006: Metadata file 'System.Reflection.dll' could not be found
# " -nostdlib " mscorlib
#		$(reference_framework System.Collections.Immutable) \

	echo -n  " -noconfig -lib:/usr/lib/mono/4.5/ "  \
		$(reference_dependency Microsoft.Build.Framework-15.9) \
		$(reference_dependency System.Collections.Immutable-2.0.0_pre) \
		$(reference_framework System.Reflection.Metadata) \
		$(reference_framework System.Threading.Tasks.Dataflow) \
		$(reference_framework System.Core) \
		$(reference_framework System.IO.Compression) \
		$(reference_framework System.IO.Compression.FileSystem) \
		$(reference_framework System.Net.Http) \
		$(reference_framework System.Runtime.Serialization) \
		$(reference_framework System.Security) \
		$(reference_framework System.Windows.Forms) \
		$(reference_framework System.Xml.Linq) \
		$(reference_framework System.Xml) \
		$(reference_framework System.Core) \
		$(reference_framework System)

#		$(reference_framework System.Xaml) \
}

# -define:<symbol list>         Define conditional compilation symbol(s) (Short form: -d)
defines() {
	for var in "$@"
	do
	    echo -n " -define:${var} "
	done
}

src_compile() {
	if ! use debug ; then
		einfo Optimizations will be enabled
		if use developer ; then
			einfo .pdb file will be created
			# DebugType=pdbonly
		else
			einfo .pdb file will not be created
		fi
	else
		einfo Optimizations will be disabled
		if use developer ; then
			einfo .pdb file and debug information will be created
			# DebugType=full
		else
			einfo .pdb file will not be created
		fi
	fi

	if ! use developer ; then
		einfo Debug symbols will not be generated
	else
		einfo Debug symbols will be generated
	fi

	cd "${S}/${PROJ_DIR}" || die
	mkdir -p $(bin_dir) || die
	ecsc $(references) $(defines "${DEFINES[@]}") /unsafe $(csharp_sources AppConfig) $(csharp_sources ../Shared/FileSystem) $(csharp_sources ResourceHandling)  ${SOURCE_FILES[*]}  $(output_dll ${PROJ})
}

src_install() {
	insinto "$(MSBuildBinPath)"
	doins "$(output_filename)"
	einstall_pc_file "Microsoft.Build.Tasks" "15.9" "$(MSBuildBinPath)/${PROJ}.dll"

	egacinstall "$(output_filename)"

	insinto "$(MSBuildToolsPath)"
	doins "${FILESDIR}/${SLOT}/Microsoft.Common.tasks"
}
