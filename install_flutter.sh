#!/bin/bash
set -e

echo "🚀 Starting Flutter build process..."

# Define Flutter home
export FLUTTER_HOME="/opt/buildhome/flutter"
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

# Fresh install
rm -rf "$FLUTTER_HOME"
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"

echo "🔧 Enabling web support..."
flutter config --enable-web

echo "📦 Getting dependencies..."
flutter pub get

echo "🏗️ Building Flutter web app..."
flutter build web --release --base-href /app/

# Move Flutter output to /app folder (for Netlify to serve separately)
echo "📁 Moving Flutter web build into /app..."
rm -rf app
mkdir app
cp -r build/web/* app/

echo "✅ Flutter web build completed successfully!"
ls -la app/
