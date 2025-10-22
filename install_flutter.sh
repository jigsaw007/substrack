#!/bin/bash
set -e

echo "🚀 Setting up build environment..."

# Install required system dependencies
echo "Installing system dependencies..."
apt-get update && apt-get install -y bash curl git unzip xz-utils libglu1-mesa || { echo "Failed to install system dependencies"; exit 1; }

echo "🚀 Installing Flutter into /opt/buildhome/flutter..."

# Clean up any existing Flutter installation
echo "Removing existing Flutter installation (if any)..."
rm -rf /opt/buildhome/flutter || { echo "Failed to remove /opt/buildhome/flutter"; exit 1; }

# Clone Flutter repository
echo "Cloning Flutter stable branch..."
git clone https://github.com/flutter/flutter.git -b stable /opt/buildhome/flutter || { echo "Failed to clone Flutter repository"; exit 1; }

# Add Flutter to PATH
export PATH="/opt/buildhome/flutter/bin:$PATH"
echo "Updated PATH: $PATH"

# Verify Flutter installation
echo "Checking Flutter version..."
/opt/buildhome/flutter/bin/flutter --version || { echo "Failed to run flutter --version"; exit 1; }

# Run Flutter doctor
echo "Running Flutter doctor..."
/opt/buildhome/flutter/bin/flutter doctor || { echo "Flutter doctor failed"; exit 1; }

# Get dependencies
echo "Running flutter pub get..."
/opt/buildhome/flutter/bin/flutter pub get || { echo "Failed to run flutter pub get"; exit 1; }

echo "✅ Flutter installed successfully!"