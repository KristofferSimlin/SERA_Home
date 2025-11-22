#!/bin/bash
set -e

# Installera Flutter (senaste stable) i buildmiljön
git clone https://github.com/flutter/flutter.git --depth 1
export PATH="$PATH:$(pwd)/flutter/bin"

# Aktivera webb, hämta dependencies och bygg
flutter config --enable-web
flutter pub get
flutter build web --release
