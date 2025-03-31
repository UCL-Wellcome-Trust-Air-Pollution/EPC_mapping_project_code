@echo off
setlocal enabledelayedexpansion

:: Set paths
set ZIP_FILE=C:\Users\uctpcke\OneDrive - University College London\Downloads\all-domestic-certificates.zip
set EXTRACT_DIR=C:\Users\uctpcke\Documents\EPC_project_code\Data\raw\epc_data\epc_data_extracted

:: Check if 7z is installed
where 7z >nul 2>nul
if errorlevel 1 (
    echo 7-Zip not found! Please install 7-Zip and make sure it's in your PATH.
    exit /b 1
)

:: Step 1: Unzip the parent folder
echo Unzipping the folder %ZIP_FILE%...
7z x "%ZIP_FILE%" -o"%EXTRACT_DIR%" -y

:: Delete initial zip folder
del %ZIP_FILE%

echo Processing complete. The extracted CSV files are saved in "%EXTRACT_DIR%".
endlocal