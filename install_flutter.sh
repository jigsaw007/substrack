#!/bin/bash
set -e

echo "🚀 Starting Flutter build process..."

export FLUTTER_HOME="/opt/buildhome/flutter"
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

echo "📦 Installing Flutter..."
rm -rf "$FLUTTER_HOME"
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"

echo "🔍 Verifying Flutter installation..."
flutter --version

echo "📥 Installing dependencies..."
flutter pub get

echo "🏗️ Building Flutter web app..."
flutter build web --release


# ✅ Move built files into the /app directory
rm -rf app
mkdir -p app
cp -r build/web/* app/

echo "✅ Build complete! Web files copied to /app/"
