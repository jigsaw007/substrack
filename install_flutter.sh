#!/bin/bash
set -e

echo "🚀 Starting Flutter web build process..."

# Create Flutter directory
export FLUTTER_HOME="/opt/buildhome/flutter"
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

echo "📦 Setting up Flutter..."

# Install Flutter from scratch
rm -rf "$FLUTTER_HOME"
git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"

# Verify Flutter installation
echo "🔍 Verifying Flutter installation..."
"$FLUTTER_HOME/bin/flutter" --version

# Navigate to project directory
cd /opt/build/repo

echo "📥 Installing Flutter dependencies..."
"$FLUTTER_HOME/bin/flutter" pub get

echo "🔧 Setting up Flutter for web..."
"$FLUTTER_HOME/bin/flutter" config --enable-web

echo "🏗️ Building web release..."
"$FLUTTER_HOME/bin/flutter" build web --release --verbose

echo "✅ Build completed successfully!"
echo "📁 Build output:"
ls -la build/web/