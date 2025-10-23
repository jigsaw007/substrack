#!/bin/bash
set -e

echo "🚀 Starting Flutter build process..."

# Define Flutter directory
export FLUTTER_HOME="/opt/buildhome/flutter"
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

# 🧹 Clean up any old Flutter installation
rm -rf "$FLUTTER_HOME"
echo "📦 Installing Flutter..."
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"

# 🧠 Verify Flutter installation
flutter --version

# 📥 Get project dependencies
echo "📥 Installing project dependencies..."
flutter pub get

# ⚙️ Enable web and build
flutter config --enable-web
echo "🏗️ Building Flutter web release (for /app)..."
flutter build web --release --base-href /app/

# 📁 Copy the build output into /app for Netlify
echo "📦 Preparing Netlify app folder..."
rm -rf app
mkdir -p app
cp -r build/web/* app/

# ✅ Done!
echo "✅ Flutter build completed successfully!"
echo "📁 Build output copied to: app/"
ls -la app/
