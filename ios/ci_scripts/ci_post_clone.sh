#!/bin/sh
set -e

# Install Flutter SDK (skip if already present from cache)
if [ ! -d "$HOME/flutter" ]; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
fi
export PATH="$HOME/flutter/bin:$PATH"

flutter precache --ios

cd "$CI_PRIMARY_REPOSITORY_PATH"
flutter pub get

cd "$CI_PRIMARY_REPOSITORY_PATH/ios"
pod install
