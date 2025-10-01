@echo off

:: This script was misery to put together!

del /Q /F "%~dp0steam\*.dll"
del /Q /F "%~dp0steam\*.obj"
del /Q /F "%~dp0game.love"

cls
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
set TARGET_D=%~dp0steam
cd /d "%TARGET_D%"

:: Now that we have access to compilers the C++ portion can be built!
nmake /F nmakefile

:: Since we're still in steam and stuff is built, lets build the final bin!
echo DLL built, preparing release directory...

set BIN_D=%~dp0bin

if not exist "%BIN_D%" (
    echo Creating bin directory...
    mkdir "%BIN_D%"
)

:: Copy Steam relevant files to bin
copy /Y "%~dp0steam\luasteam.dll" "%BIN_D%"
copy /Y "%~dp0steam\steam_appid.txt" "%BIN_D%"
copy /Y "%~dp0steam\steamworks\redistributable_bin\win64\steam_api64.dll" "%BIN_D%"

:: Copy + Write Love into bin
powershell -Command "Compress-Archive -Path '%~dp0source\*' -DestinationPath '%~dp0game.zip'"
ren "%~dp0game.zip" "game.love"
copy /Y "C:\Program Files\LOVE\*.dll" "%BIN_D%"
copy /Y "C:\Program Files\LOVE\license.txt" "%BIN_D%\love_license.txt"
copy /b "C:\Program Files\LOVE\love.exe"+"%~dp0game.love" "%BIN_D%\game.exe"

:: Double check if game.love is real before we bind to exe
if not exist "%~dp0game.love" (
    echo Error! game.love wasn't produced.
    exit
)

:: XCopy assets into bin
xcopy /E /I "%~dp0assets" "%BIN_D%\assets"

echo Complete! Removing junk files...

del /Q /F "%~dp0steam\*.dll"
del /Q /F "%~dp0steam\*.obj"
del /Q /F "%~dp0game.love"
del /Q /F "%~dp0bin\assets\README.md"
del /Q /F "%~dp0steam\luasteam.exp"
del /Q /F "%~dp0steam\luasteam.lib"

echo Build complete.
@echo on