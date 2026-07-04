#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE="${ENV_FILE:-env.prod.json}"
KEY_PROPERTIES="android/key.properties"
KEYSTORE="android/upload-keystore.jks"
DEBUG_INFO_DIR="build/debug-info"

echo "==> Personal OS — Android release build"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing $ENV_FILE"
  echo "Copy env.prod.example.json to env.prod.json and fill in production values."
  exit 1
fi

if [[ ! -f "$KEY_PROPERTIES" ]]; then
  echo "==> No key.properties found — generating CI upload keystore"
  if [[ ! -f "$KEYSTORE" ]]; then
    keytool -genkey -v \
      -keystore "$KEYSTORE" \
      -keyalg RSA -keysize 2048 -validity 10000 \
      -alias upload \
      -storepass android -keypass android \
      -dname "CN=Personal OS, OU=Engineering, O=PersonalOS, L=Unknown, ST=Unknown, C=US"
  fi
  cat > "$KEY_PROPERTIES" <<EOF
storePassword=android
keyPassword=android
keyAlias=upload
storeFile=../upload-keystore.jks
EOF
  echo "    Created $KEY_PROPERTIES (replace with your Play Store signing key for production)"
fi

mkdir -p "$DEBUG_INFO_DIR"

echo "==> Running flutter pub get"
flutter pub get

echo "==> Building release app bundle (AAB)"
flutter build appbundle \
  --release \
  --dart-define-from-file="$ENV_FILE" \
  --obfuscate \
  --split-debug-info="$DEBUG_INFO_DIR"

echo ""
echo "==> Build complete"
echo "    AAB: build/app/outputs/bundle/release/app-release.aab"
echo "    Debug symbols: $DEBUG_INFO_DIR"
echo ""
echo "Upload app-release.aab to Google Play Console."
