#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

APK_FLUTTER="build/app/outputs/flutter-apk/app-debug.apk"
APK_GRADLE="build/app/outputs/apk/debug/app-debug.apk"

echo "==> Personal OS — Android debug APK build"
echo "    Project: $ROOT_DIR"

echo "==> Cleaning old build artifacts"
rm -rf build android/.gradle android/app/build android/build

flutter clean
flutter pub get

(cd android && ./gradlew --stop 2>/dev/null || true)

echo "==> Building debug APK"
flutter build apk --debug --no-tree-shake-icons

if [[ -f "$APK_FLUTTER" ]]; then
  echo ""
  echo "==> BUILD SUCCEEDED"
  echo "    APK: $ROOT_DIR/$APK_FLUTTER"
  ls -lh "$APK_FLUTTER"
elif [[ -f "$APK_GRADLE" ]]; then
  echo ""
  echo "==> BUILD SUCCEEDED"
  echo "    APK: $ROOT_DIR/$APK_GRADLE"
  ls -lh "$APK_GRADLE"
else
  echo ""
  echo "==> BUILD REPORTED SUCCESS BUT APK NOT FOUND"
  find "$ROOT_DIR" -name '*.apk' -type f 2>/dev/null || true
  exit 1
fi
