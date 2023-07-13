#!/bin/sh
brew install ruby@2.5
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc

ruby --version
# # Install CocoaPods using Homebrew.
brew install cocoapods

# # Install Flutter
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_2.0.6-stable.zip
unzip flutter_macos_2.0.6-stable.zip


export PATH="$PATH:`pwd`/flutter/bin"

# # Run Flutter doctor
flutter doctor


# # Enable macos
flutter config --enable-macos-desktop

# # Get packages
flutter packages get

# # Update generated files
# # flutter pub run build_runner build

# # Build ios app
flutter build ios --no-codesign