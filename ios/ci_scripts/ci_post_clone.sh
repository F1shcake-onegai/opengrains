#!/bin/sh
set -e

# Install Flutter SDK
git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
export PATH="$HOME/flutter/bin:$PATH"

flutter precache --ios
flutter pub get

cd ios
pod install
