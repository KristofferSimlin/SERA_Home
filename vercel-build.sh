#!/bin/bash
set -e

# Use latest stable Flutter (aligns with intl 0.20.x)
FLUTTER_VERSION="stable"
git clone https://github.com/flutter/flutter.git --branch "$FLUTTER_VERSION" --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Aktivera webb, hämta dependencies och bygg
flutter config --enable-web
flutter pub get
flutter build web --release
