#!/bin/bash
set -e

echo "🚀 Setting up build environment..."

# Install system dependencies
echo "Installing system dependencies..."
apt-get update && apt-get install -y bash curl git unzip xz-utils libglu1-mesa clang cmake ninja-build || {
  echo "Failed to install system dependencies"
  exit 1
}

echo "🚀 Installing Flutter into /opt/buildhome/flutter..."

# Check if Flutter is already cached
if [ ! -d "/opt/buildhome/flutter" ]; then
  echo "Cloning Flutter stable branch..."
  git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/flutter || {
    echo "Failed to clone Flutter repository"
    exit 1
  }
else
  echo "Flutter already exists, updating..."
  /opt/buildhome/flutter/bin/flutter upgrade || {
    echo "Failed to update Flutter"
    exit 1
  }
fi

# Add Flutter to PATH
export PATH="/opt/buildhome/flutter/bin:$PATH"
echo "Updated PATH: $PATH"

# Verify Flutter installation
echo "Checking Flutter version..."
/opt/buildhome/flutter/bin/flutter --version || {
  echo "Failed to run flutter --version"
  exit 1
}

# Run Flutter doctor (allow non-zero exit code for web builds)
echo "Running Flutter doctor..."
/opt/buildhome/flutter/bin/flutter doctor || echo "Flutter doctor completed with warnings, continuing..."

# Get dependencies
echo "Running flutter pub get..."
cd /opt/build/repo # Ensure we're in the repo directory
/opt/buildhome/flutter/bin/flutter pub get || {
  echo "Failed to run flutter pub get"
  exit 1
}

echo "✅ Flutter installed successfully!"