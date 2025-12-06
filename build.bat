

:::::::::::::::::::::::::::::::::::
:: Photoshop plugin build script ::
:::::::::::::::::::::::::::::::::::

@echo off
setlocal

echo Build script started executing at %time% ...
set BuildType=%1
if "%BuildType%"=="" (set BuildType=release)

:: Photoshop SDK path
set PhotoshopSDKRoot="C:\C libraries\psapi"
:: Path to CnvtPiPL.exe tool
set CnvtPiPLExePath="C:\Weird tools\abobe\Cnvtpipl.exe"
:: Path to deploy built Photoshop plugins
set PhotoshopPluginsDeployPath="C:\C-Related"

:: Path to ZXPSignCmd.exe certificate signer
set ZXPSignCmdExe="C:\Weird tools\abobe\ZXPSignCmd.exe"
:: Path to certificate
set ZXPCert="C:\C-Related\cert.p12"
:: Certificate password
set ZXPCertPassword=123pswd

:: Call to the MSVC compiler
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64

::: Compilation settings :::

:: Build directory (creates one if absent)
set BuildDir=%~dp0msbuild
if not exist %BuildDir% mkdir %BuildDir%
pushd %BuildDir%

:: Plugin name
set ProjectName=tutorial_automation

:: Files to compile
set EntryPoint=%~dp0src\%ProjectName%_main.cpp
set ResourcePiPL=%~dp0src\%ProjectName%_pipl.r
set ResourceRC=%BuildDir%\%ProjectName%_pipl.rc
set ResourceRES=%BuildDir%\%ProjectName%_pipl.res

:: Photoshop SDK path
:: The script all the SDK headers to reside in that folder
set ThirdPartyDirPath=C:\C libraries\psapi

:: Output binary path
set OutBin=%BuildDir%\%ProjectName%.8li

set CommonLinkerFlags=/dll /incremental:no /machine:x64 /nologo /defaultlib:Kernel32.lib /defaultlib:User32.lib /defaultlib:Shell32.lib /nodefaultlib:LIBCMTD.lib /nodefaultlib:LIBCMT.lib "%ResourceRES%"
set DebugLinkerFlags=%CommonLinkerFlags% /opt:noref /debug /pdb:"%BuildDir%\%ProjectName%.pdb"
set ReleaseLinkerFlags=%CommonLinkerFlags% /opt:ref
set RelWithDebInfoLinkerFlags=%CommonLinkerFlags% /opt:ref /debug /pdb:"%BuildDir%\%ProjectName%.pdb"

set PSPreprocessorDefines=/DISOLATION_AWARE_ENABLED=1 /DWIN32=1 /D_CRT_SECURE_NO_DEPRECATE /D_SCL_SECURE_NO_DEPRECATE /D_WINDOWS /D_USRDLL /D_WINDLL /D_MBCS
set PSCompilerFlags=/EHsc
set CommonIncludePaths=/I "%ThirdPartyDirPath%"
set CommonCompilerFlags=/nologo /W3 /WX %CommonIncludePaths% /Zc:__cplusplus /arch:AVX2 %PSCompilerFlags% %PSPreprocessorDefines%
set CompilerFlagsDebug=%CommonCompilerFlags% /Od /Zi /D_DEBUG /MDd
set CompilerFlagsRelease=%CommonCompilerFlags% /Ox /DNDEBUG /MD
set CompilerFlagsRelWithDebInfo=%CommonCompilerFlags% /Ox /Zi /DNDEBUG /MD


echo 5

if "%BuildType%"=="debug" (
    set BuildCommand=cl %CompilerFlagsDebug% "%EntryPoint%" /Fe:"%OutBin%" /link %DebugLinkerFlags%
    set BuildRRCommand=cl /EP /DMSWindows=1 /Tc "%ResourcePiPL%" %CompilerFlagsDebug%
) else if "%BuildType%"=="relwithdebinfo" (
    set BuildCommand=cl %CompilerFlagsRelWithDebInfo% "%EntryPoint%" /Fe:"%OutBin%" /link %RelWithDebInfoLinkerFlags%
    set BuildRRCommand=cl /EP /DMSWindows=1 /Tc "%ResourcePiPL%" %CompilerFlagsRelWithDebInfo% 
) else (
    set BuildCommand=cl %CompilerFlagsRelease% "%EntryPoint%" /Fe:"%OutBin%" /link %ReleaseLinkerFlags%
    set BuildRRCommand=cl /EP /DMSWindows=1 /Tc "%ResourcePiPL%" %CompilerFlagsRelease%
)

echo 6

echo.
echo Compiling resources (command follows below)...
set ResourceRR=%BuildDir%\%ProjectName%_pipl.rr

echo 7

echo BuildType is: %BuildType%
echo BuildRRCommand is: %BuildRRCommand%
echo ResourceRR is: %ResourceRR%

echo %BuildRRCommand%
%BuildRRCommand% > "%ResourceRR%"
if %errorlevel% neq 0 goto error

echo 8

echo.
echo Converting PiPL to  Windows resource file format...
echo %CnvtPiPLExePath% "%ResourceRR%" "%ResourceRC%"
%CnvtPiPLExePath% "%ResourceRR%" "%ResourceRC%"
if %errorlevel% neq 0 goto error

echo 9

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

if "%BuildType%"=="debug" (
    copy /Y "%BuildDir%\%ProjectName%.pdb" "%PhotoshopPluginsDeployPath%"
    if %errorlevel% neq 0 goto error
)

set OutZXP=%BuildDir%\%ProjectName%.zxp
set BuildZXPCommand=%ZXPSignCmdExe% -sign "%~dp0msbuild" "%OutZXP%" "%ZXPCert%" %ZXPCertPassword%

echo.
echo Building ZXP Photoshop extension package (command follows below)...
echo %BuildZXPCommand%

%BuildZXPCommand%

if %errorlevel% neq 0 goto error

if %errorlevel% == 0 goto success


:error
echo.
echo ***************************************
echo *      !!! An error occurred!!!       *
echo ***************************************
goto end


:success
echo.
echo ***************************************
echo *    Build completed successfully.    *
echo ***************************************
goto end


:end
echo.
echo Build script finished execution at %time%.
pause
popd


endlocal
exit /b %errorlevel%