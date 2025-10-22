#!/bin/bash
set -e

echo "🚀 Installing Flutter into /opt/buildhome/flutter..."

# Clean any previous Flutter folder (safe)
rm -rf /opt/buildhome/flutter

# Clone the stable channel
git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/flutter

# Add to PATH (for this shell)
export PATH="/opt/buildhome/flutter/bin:$PATH"

# Verify installation
flutter --version
flutter doctor
flutter pub get

echo "✅ Flutter installed successfully."
