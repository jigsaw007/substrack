#!/bin/bash
set -e

echo "🚀 Installing Flutter into /opt/buildhome/flutter..."

rm -rf /opt/buildhome/flutter
git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/flutter

export PATH="/opt/buildhome/flutter/bin:$PATH"

flutter --version
flutter doctor
flutter pub get

echo "✅ Flutter installed successfully!"
