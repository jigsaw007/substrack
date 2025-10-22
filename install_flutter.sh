#!/bin/bash
set -e

echo "🚀 Starting Flutter web build process..."

# Define Flutter directory
export FLUTTER_HOME="/opt/buildhome/flutter"
export PATH="$FLUTTER_HOME/bin:$FLUTTER_HOME/bin/cache/dart-sdk/bin:$PATH"

echo "📦 Setting up Flutter..."

# Install Flutter if not present
if [ ! -d "$FLUTTER_HOME" ]; then
    echo "🔧 Cloning Flutter stable branch..."
    git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_HOME"
else
    echo "🔄 Flutter exists, updating..."
    cd "$FLUTTER_HOME"
    git fetch origin stable
    git checkout stable
    git pull origin stable
fi

# Verify we can run flutter
echo "🔍 Flutter version:"
$FLUTTER_HOME/bin/flutter --version

# Navigate to project root
cd /opt/build/repo

echo "📥 Installing Flutter dependencies..."
$FLUTTER_HOME/bin/flutter pub get

echo "🔧 Configuring Flutter for web..."
$FLUTTER_HOME/bin/flutter config --enable-web

echo "🏗️ Building web release..."
$FLUTTER_HOME/bin/flutter build web --release --verbose

echo "✅ Build completed successfully!"
ls -la build/web/