@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0.."
echo ==^> Personal OS - Android debug APK build
echo Project: %CD%

echo ==^> Cleaning old build artifacts
if exist build rmdir /s /q build
if exist android\.gradle rmdir /s /q android\.gradle
if exist android\app\build rmdir /s /q android\app\build

echo ==^> flutter clean
call flutter clean
if errorlevel 1 exit /b 1

echo ==^> flutter pub get
call flutter pub get
if errorlevel 1 exit /b 1

echo ==^> Stopping Gradle daemons
cd android
call gradlew.bat --stop 2>nul
cd ..

echo ==^> Building debug APK
call flutter build apk --debug --no-tree-shake-icons
if errorlevel 1 (
  echo.
  echo BUILD FAILED. Check Kotlin/Gradle errors above.
  exit /b 1
)

set APK_FLUTTER=build\app\outputs\flutter-apk\app-debug.apk
set APK_GRADLE=build\app\outputs\apk\debug\app-debug.apk

echo.
if exist "%APK_FLUTTER%" (
  echo BUILD SUCCEEDED
  echo APK: %CD%\%APK_FLUTTER%
  for %%A in ("%APK_FLUTTER%") do echo Size: %%~zA bytes
) else if exist "%APK_GRADLE%" (
  echo BUILD SUCCEEDED
  echo APK: %CD%\%APK_GRADLE%
  for %%A in ("%APK_GRADLE%") do echo Size: %%~zA bytes
) else (
  echo BUILD REPORTED SUCCESS BUT APK NOT FOUND.
  echo Searched:
  echo   %CD%\%APK_FLUTTER%
  echo   %CD%\%APK_GRADLE%
  dir /s /b *.apk 2>nul
  exit /b 1
)

endlocal
