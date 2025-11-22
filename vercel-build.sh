#!/bin/bash
set -e

# Pin a stable Flutter version to avoid SDK mismatch in CI
FLUTTER_VERSION="3.24.4"
git clone https://github.com/flutter/flutter.git --branch "$FLUTTER_VERSION" --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Aktivera webb, hämta dependencies och bygg
flutter config --enable-web
flutter pub get
flutter build web --release
