#!/bin/bash

# Clean the project
flutter clean

# Get dependencies
flutter pub get

# Run tests
flutter test

# Build APK
flutter build apk --release

# Move APK to a more accessible location
mkdir -p build/output
cp build/app/outputs/flutter-apk/app-release.apk build/output/medway.apk

echo "APK built successfully at build/output/medway.apk" 