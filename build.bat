
@echo off
setlocal

set PhotoshopSDKRoot="C:\C libraries\psapi"
set PhotoshopPluginsDeployPath="C:\C-Related"

set ZXPSignCmdExe="C:\Weird tools\abobe\ZXPSignCmd.exe"
set ZXPCert="C:\C-Related\cert.p12"
set ZXPCertPassword=123pswd

call "%vs2017installdir%\VC\Auxiliary\Build\vcvarsall.bat" x64

set BuildDir=%~dp0msbuild
if not exist %BuildDir% mkdir %BuildDir%
pushd %BuildDir%


set ProjectName=tutorial_automation

set EntryPoint=%~dp0src\%ProjectName%_main.cpp
set ResourcePiPL=%~dp0src\%ProjectName%_pipl.r
set ResourceRC=%BuildDir%\%ProjectName%_pipl.rc
set ResourceRES=%BuildDir%\%ProjectName%_pipl.res

set ThirdPartyDirPath=%~dp0..\thirdparty

set OutBin=%BuildDir%\%ProjectName%.8li

set CommonLinkerFlags=/dll /incremental:no /machine:x64 /nologo /defaultlib:Kernel32.lib /defaultlib:User32.lib /defaultlib:Shell32.lib /nodefaultlib:LIBCMTD.lib /nodefaultlib:LIBCMT.lib "%ResourceRES%"
set DebugLinkerFlags=%CommonLinkerFlags% /opt:noref /debug /pdb:"%BuildDir%\%ProjectName%.pdb"
set ReleaseLinkerFlags=%CommonLinkerFlags% /opt:ref
set RelWithDebInfoLinkerFlags=%CommonLinkerFlags% /opt:ref /debug /pdb:"%BuildDir%\%ProjectName%.pdb"

set PSPreprocessorDefines=/DISOLATION_AWARE_ENABLED=1 /DWIN32=1 /D_CRT_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_DEPRECATE /D_WINDOWS /D_USRDLL /D_WINDLL /D_MBCS
set PSCompilerFlags=/EHsc
set CommonIncludePaths=/I "%ThirdPartyDirPath%" /I "%ThirdPartyDirPath%\psapi\common\includes" /I "%ThirdPartyDirPath%\psapi\common\resources" /I "%ThirdPartyDirPath%\psapi\common\sources" /I "%ThirdPartyDirPath%\psapi\photoshop" /I "%ThirdPartyDirPath%\psapi\pica_sp" /I "%ThirdPartyDirPath%\psapi\resources" /I "%ThirdPartyDirPath%\psapi\ai" /I "%BuildDir%"
set CommonCompilerFlags=/nologo /W3 /WX %CommonIncludePaths% /Zc:__cplusplus /arch:AVX2 %PSCompilerFlags% %PSPreprocessorDefines%
set CompilerFlagsDebug=%CommonCompilerFlags% /Od /Zi /D_DEBUG /MDd
set CompilerFlagsRelease=%CommonCompilerFlags% /Ox /DNDEBUG /MD
set CompilerFlagsRelWithDebInfo=%CommonCompilerFlags% /Ox /Zi /DNDEBUG /MD



echo.
echo Compiling resources (command follows below)...
set ResourceRR=%BuildDir%\%ProjectName%_pipl.rr

echo %BuildRRCommand%
%BuildRRCommand% > "%ResourceRR%"
if %errorlevel% neq 0 goto error

echo.
echo Converting PiPL to  Windows resource file format...
%CnvtPiPLExePath% "%ResourceRR%" "%ResourceRC%"
if %errorlevel% neq 0 goto error

echo.
echo Compiling Windows Resources...
rc /v /fo "%ResourceRES%" "%ResourceRC%"
if %errorlevel% neq 0 goto error

echo.
echo Compiling source files for automation filter (command follows below)...
echo %BuildCommand%
echo.
echo Output from compilation:
%BuildCommand%
if %errorlevel% neq 0 goto error


echo.
echo Deploying built binaries and symbols...
copy /Y "%OutBin%"  "%PhotoshopPluginsDeployPath%"
if %errorlevel% neq 0 goto error

copy /Y "%BuildDir%\%ProjectName%.pdb" "%PhotoshopPluginsDeployPath%"
if %errorlevel% neq 0 goto error