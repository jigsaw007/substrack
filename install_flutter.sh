#!/bin/bash
set -e

echo "🚀 Setting up build environment..."

# Install system dependencies (skip sudo — Netlify build containers already run as root)
apt-get update && apt-get install -y \
  bash curl git unzip xz-utils libglu1-mesa clang cmake ninja-build

echo "🚀 Installing Flutter into /opt/buildhome/flutter..."

# Install Flutter if missing
if [ ! -d "/opt/buildhome/flutter" ]; then
  echo "Cloning Flutter stable branch..."
  git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/flutter
else
  echo "Flutter already exists, updating..."
  /opt/buildhome/flutter/bin/flutter upgrade
fi

# Add Flutter to PATH
export PATH="/opt/buildhome/flutter/bin:$PATH"
echo "PATH set to: $PATH"

# Verify installation
/opt/buildhome/flutter/bin/flutter --version
/opt/buildhome/flutter/bin/flutter doctor || echo "⚠️ Flutter doctor warnings ignored"

# Get dependencies
cd /opt/build/repo
/opt/buildhome/flutter/bin/flutter pub get

echo "✅ Flutter setup complete!"
