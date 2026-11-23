#!/usr/bin/env bash
set -euo pipefail

if [ ! -f android/gradlew ]; then
  flutter create --platforms=android --org com.studylink --project-name studylink .
fi

flutter pub get
dart format .
flutter analyze
flutter test
flutter build apk --debug
