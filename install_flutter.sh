#!/bin/bash
set -e

echo "🚀 Installing Flutter into /opt/buildhome/flutter..."

# Clean and reinstall Flutter
rm -rf /opt/buildhome/flutter
git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/flutter

# Add Flutter to PATH for current shell
export PATH="/opt/buildhome/flutter/bin:$PATH"

# Verify installation
flutter --version
flutter doctor

# Get project dependencies
flutter pub get

echo "✅ Flutter installed successfully."
