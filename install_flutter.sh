#!/bin/bash
set -e

echo "🚀 Installing Flutter into /opt/buildhome/flutter..."

# Clean and install Flutter SDK
rm -rf /opt/buildhome/flutter
git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/flutter

# Add Flutter to PATH
export PATH="/opt/buildhome/flutter/bin:$PATH"

flutter --version
flutter doctor

# Get project dependencies
flutter pub get

echo "✅ Flutter installed successfully!"
