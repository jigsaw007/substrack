#!/bin/bash
set -e

echo "🚀 Starting Flutter build process..."

# Define Flutter environment
export FLUTTER_HOME="/opt/buildhome/flutter"
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

# Clean and install Flutter fresh
rm -rf "$FLUTTER_HOME"
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"

flutter --version
flutter config --enable-web

echo "📦 Installing dependencies..."
flutter pub get

echo "🏗️ Building Flutter web release..."
flutter build web --release --base-href /app/

# Copy Flutter build into /app folder
echo "📁 Moving Flutter build to /app..."
mkdir -p app
cp -r build/web/* app/

# Cleanup to reduce Netlify deploy size
rm -rf build/

echo "✅ Done! /app folder ready:"
ls -la app/
