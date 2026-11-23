#!/usr/bin/env bash
set -euo pipefail

if [ ! -f android/gradlew ]; then
  flutter create --platforms=android --org com.studylink --project-name studylink .
else
  echo "Android runner already exists."
fi
