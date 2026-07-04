#!/usr/bin/env bash
# Source this file to add Flutter to PATH in any shell session:
#   source scripts/flutter_env.sh

export FLUTTER_ROOT="${FLUTTER_ROOT:-$HOME/flutter}"
export FLUTTER_GIT_URL="${FLUTTER_GIT_URL:-https://github.com/flutter/flutter.git}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/android-sdk}"
export PATH="$FLUTTER_ROOT/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
