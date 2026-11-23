# Android platform runner

This feature branch contains the Flutter application source. If the Android Gradle wrapper and runner files are not present, generate the standard Android platform files from the project root using:

```bash
flutter create --platforms=android --org com.studylink --project-name studylink .
```

Then run `flutter run` or `flutter build apk`. Keep the generated Android files in this directory when committing the final mobile app.
