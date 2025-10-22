#!/bin/bash
set -e

echo "🚀 Setting up Flutter build (Noble-compatible)..."

# Define Flutter directory
export FLUTTER_HOME=/opt/buildhome/flutter
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

# If Flutter not already cached, clone it
if [ ! -d "$FLUTTER_HOME" ]; then
  echo "📦 Cloning Flutter stable branch..."
  git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"
else
  echo "🔁 Flutter already exists, updating..."
  cd "$FLUTTER_HOME"
  git fetch
  git pull
fi

# Verify Flutter install
flutter --version || $FLUTTER_HOME/bin/flutter --version

# Go back to repo root
cd /opt/build/repo

echo "📥 Fetching dependencies..."
$FLUTTER_HOME/bin/flutter pub get

echo "🏗️ Building web release..."
$FLUTTER_HOME/bin/flutter build web --release

echo "✅ Flutter web build completed successfully!"
