@echo off
title Bibata Modern Ice Cursor Installer

:: Detect system language
for /f "tokens=3" %%a in ('reg query "HKCU\Control Panel\International" /v LocaleName 2^>nul ^| find "LocaleName"') do set "LOCALE=%%a"
if "%LOCALE:~0,2%"=="tr" (
    set "LANG=TR"
) else (
    set "LANG=EN"
)

:: Set messages based on language
if "%LANG%"=="TR" (
    set "MSG_TITLE=Bibata Modern Ice Cursor - Otomatik Kurulum"
    set "MSG_DOWNLOAD=[1/4] Bibata-Modern-Ice-Windows.zip indiriliyor..."
    set "MSG_DOWNLOAD_DONE=     Indirme tamamlandi."
    set "MSG_EXTRACT=[2/4] Zip dosyasi cikariliyor..."
    set "MSG_EXTRACT_DONE=     Cikarma tamamlandi."
    set "MSG_INSTALL=[3/4] Cursor temasi kuruluyor (Yonetici izni gerekebilir)..."
    set "MSG_INSTALL_DONE=     Kurulum tamamlandi."
    set "MSG_APPLY=[4/4] Cursor temasi uygulaniyor..."
    set "MSG_APPLY_DONE=     Cursor temasi uygulandi."
    set "MSG_CLEANUP=Gecici dosyalar temizleniyor..."
    set "MSG_SUCCESS=Kurulum basariyla tamamlandi!"
    set "MSG_ERR_DOWNLOAD=HATA: Dosya indirilemedi!"
    set "MSG_ERR_EXTRACT=HATA: Zip dosyasi cikartilamadi!"
    set "MSG_ERR_INSTALL=HATA: Kurulum basarisiz!"
) else (
    set "MSG_TITLE=Bibata Modern Ice Cursor - Auto Installer"
    set "MSG_DOWNLOAD=[1/4] Downloading Bibata-Modern-Ice-Windows.zip..."
    set "MSG_DOWNLOAD_DONE=     Download completed."
    set "MSG_EXTRACT=[2/4] Extracting zip file..."
    set "MSG_EXTRACT_DONE=     Extraction completed."
    set "MSG_INSTALL=[3/4] Installing cursor theme (Admin permission may be required)..."
    set "MSG_INSTALL_DONE=     Installation completed."
    set "MSG_APPLY=[4/4] Applying cursor theme..."
    set "MSG_APPLY_DONE=     Cursor theme applied."
    set "MSG_CLEANUP=Cleaning up temporary files..."
    set "MSG_SUCCESS=Installation completed successfully!"
    set "MSG_ERR_DOWNLOAD=ERROR: Failed to download file!"
    set "MSG_ERR_EXTRACT=ERROR: Failed to extract zip file!"
    set "MSG_ERR_INSTALL=ERROR: Installation failed!"
)

echo ============================================
echo  %MSG_TITLE%
echo ============================================
echo.

set "DOWNLOAD_URL=https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice-Windows.zip"
set "TEMP_DIR=%TEMP%\BibataCursor"
set "ZIP_FILE=%TEMP_DIR%\Bibata-Modern-Ice-Windows.zip"
set "EXTRACT_DIR=%TEMP_DIR%\Bibata-Modern-Ice-Windows"
set "CURSOR_DIR=%EXTRACT_DIR%\Bibata-Modern-Ice-Regular-Windows"

:: Create temp folder
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

:: Download
echo %MSG_DOWNLOAD%
curl -L -o "%ZIP_FILE%" "%DOWNLOAD_URL%"
if %errorlevel% neq 0 (
    echo %MSG_ERR_DOWNLOAD%
    timeout /t 5 /nobreak >nul
    exit /b 1
)
echo %MSG_DOWNLOAD_DONE%
echo.

:: Extract
echo %MSG_EXTRACT%
powershell -NoProfile -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force"
if %errorlevel% neq 0 (
    echo %MSG_ERR_EXTRACT%
    timeout /t 5 /nobreak >nul
    exit /b 1
)
echo %MSG_EXTRACT_DONE%
echo.

:: Remove mouse properties window trigger from install.inf
powershell -NoProfile -Command "(Get-Content '%CURSOR_DIR%\install.inf') -replace '.*rundll32.exe shell32.dll,Control_RunDLL main.cpl.*', '' | Set-Content '%CURSOR_DIR%\install.inf'"

:: Install (as admin)
echo %MSG_INSTALL%
powershell -NoProfile -Command "Start-Process rundll32.exe -ArgumentList 'setupapi.dll,InstallHinfSection DefaultInstall 132 %CURSOR_DIR%\install.inf' -Verb RunAs -Wait"
if %errorlevel% neq 0 (
    echo %MSG_ERR_INSTALL%
    timeout /t 5 /nobreak >nul
    exit /b 1
)
echo %MSG_INSTALL_DONE%
echo.

:: Apply cursor theme automatically
echo %MSG_APPLY%
powershell -NoProfile -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class CursorHelper { [DllImport(\"user32.dll\", SetLastError = true)] public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni); }'; [CursorHelper]::SystemParametersInfo(0x0057, 0, 'Bibata-Modern-Ice-Regular Cursors', 0x01 -bor 0x02)"
echo %MSG_APPLY_DONE%
echo.

:: Cleanup
echo %MSG_CLEANUP%
rmdir /s /q "%TEMP_DIR%"

echo.
echo ============================================
echo  %MSG_SUCCESS%
echo ============================================
echo.
timeout /t 5 /nobreak >nul
