#!/bin/bash
set -e

# Install Flutter from GitHub stable channel
git clone https://github.com/flutter/flutter.git -b stable --depth 1

# Add Flutter to PATH
export PATH="$PATH:`pwd`/flutter/bin"

# Verify installation
flutter doctor
flutter --version
flutter pub get
