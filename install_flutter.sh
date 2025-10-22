#!/bin/bash
set -e

echo "🚀 Starting Flutter build process..."

# Set up Flutter environment
export FLUTTER_HOME="/opt/buildhome/flutter"
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

echo "📦 Installing Flutter..."
# Remove existing installation and start fresh
rm -rf "$FLUTTER_HOME"
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"

echo "🔍 Verifying Flutter installation..."
flutter --version

echo "📥 Installing project dependencies..."
flutter pub get

echo "🔧 Setting up Flutter web..."
flutter config --enable-web

echo "🏗️ Building web release..."
flutter build web --release --verbose

echo "✅ Flutter build completed successfully!"
echo "📁 Build output location: build/web/"
ls -la build/web/