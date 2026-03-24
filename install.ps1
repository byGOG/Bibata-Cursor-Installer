# Bibata Modern Ice Cursor - Auto Installer
# Usage: irm https://raw.githubusercontent.com/byGOG/Bibata-Cursor-Installer/master/install.ps1 | iex

$DOWNLOAD_URL = "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice-Windows.zip"
$TEMP_DIR = "$env:TEMP\BibataCursor"
$ZIP_FILE = "$TEMP_DIR\Bibata-Modern-Ice-Windows.zip"
$EXTRACT_DIR = "$TEMP_DIR\Bibata-Modern-Ice-Windows"
$CURSOR_DIR = "$EXTRACT_DIR\Bibata-Modern-Ice-Regular-Windows"

# Detect language
$locale = (Get-Culture).Name
if ($locale -like "tr*") {
    $msg = @{
        title    = "Bibata Modern Ice Cursor - Otomatik Kurulum"
        dl       = "[1/4] Bibata-Modern-Ice-Windows.zip indiriliyor..."
        dlDone   = "      Indirme tamamlandi."
        ext      = "[2/4] Zip dosyasi cikariliyor..."
        extDone  = "      Cikarma tamamlandi."
        inst     = "[3/4] Cursor temasi kuruluyor (Yonetici izni gerekebilir)..."
        instDone = "      Kurulum tamamlandi."
        apply    = "[4/4] Cursor temasi uygulaniyor..."
        applyDone= "      Cursor temasi uygulandi."
        cleanup  = "Gecici dosyalar temizleniyor..."
        success  = "Kurulum basariyla tamamlandi!"
        errDl    = "HATA: Dosya indirilemedi!"
        errExt   = "HATA: Zip dosyasi cikartilamadi!"
        errInst  = "HATA: Kurulum basarisiz!"
    }
} else {
    $msg = @{
        title    = "Bibata Modern Ice Cursor - Auto Installer"
        dl       = "[1/4] Downloading Bibata-Modern-Ice-Windows.zip..."
        dlDone   = "      Download completed."
        ext      = "[2/4] Extracting zip file..."
        extDone  = "      Extraction completed."
        inst     = "[3/4] Installing cursor theme (Admin permission may be required)..."
        instDone = "      Installation completed."
        apply    = "[4/4] Applying cursor theme..."
        applyDone= "      Cursor theme applied."
        cleanup  = "Cleaning up temporary files..."
        success  = "Installation completed successfully!"
        errDl    = "ERROR: Failed to download file!"
        errExt   = "ERROR: Failed to extract zip file!"
        errInst  = "ERROR: Installation failed!"
    }
}

Write-Host "============================================"
Write-Host " $($msg.title)"
Write-Host "============================================"
Write-Host ""

# Create temp folder
if (Test-Path $TEMP_DIR) { Remove-Item $TEMP_DIR -Recurse -Force }
New-Item -ItemType Directory -Path $TEMP_DIR -Force | Out-Null

# Download (curl is faster than Invoke-WebRequest)
Write-Host $msg.dl
& curl.exe -L -o $ZIP_FILE $DOWNLOAD_URL --silent --show-error
if ($LASTEXITCODE -ne 0) {
    Write-Host $msg.errDl
    Start-Sleep -Seconds 5
    return
}
Write-Host $msg.dlDone
Write-Host ""

# Extract
Write-Host $msg.ext
try {
    Expand-Archive -Path $ZIP_FILE -DestinationPath $EXTRACT_DIR -Force
    Write-Host $msg.extDone
} catch {
    Write-Host $msg.errExt
    Start-Sleep -Seconds 5
    return
}
Write-Host ""

# Remove mouse properties window trigger from install.inf
$infPath = "$CURSOR_DIR\install.inf"
$content = Get-Content $infPath
$content = $content -replace '.*rundll32.exe shell32.dll,Control_RunDLL main.cpl.*', ''
Set-Content -Path $infPath -Value $content

# Install (as admin)
Write-Host $msg.inst
try {
    Start-Process rundll32.exe -ArgumentList "setupapi.dll,InstallHinfSection DefaultInstall 132 $infPath" -Verb RunAs -Wait
    Write-Host $msg.instDone
} catch {
    Write-Host $msg.errInst
    Start-Sleep -Seconds 5
    return
}
Write-Host ""

# Apply cursor theme
Write-Host $msg.apply
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class CursorHelper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, string pvParam, uint fWinIni);
}
"@
[CursorHelper]::SystemParametersInfo(0x0057, 0, "Bibata-Modern-Ice-Regular Cursors", 0x03) | Out-Null
Write-Host $msg.applyDone
Write-Host ""

# Cleanup
Write-Host $msg.cleanup
Remove-Item $TEMP_DIR -Recurse -Force

Write-Host ""
Write-Host "============================================"
Write-Host " $($msg.success)"
Write-Host "============================================"
Write-Host ""
Start-Sleep -Seconds 5
