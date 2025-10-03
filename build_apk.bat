@echo off

REM Clean the project
flutter clean

REM Get dependencies
flutter pub get

REM Run tests
flutter test

REM Build APK
flutter build apk --release

REM Create output directory and copy APK
if not exist build\output mkdir build\output
copy /Y build\app\outputs\flutter-apk\app-release.apk build\output\medway.apk

echo APK built successfully at build\output\medway.apk 