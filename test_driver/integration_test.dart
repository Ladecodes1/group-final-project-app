import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final screenshotsDirectory = Directory('docs/screenshots');
  await screenshotsDirectory.create(recursive: true);

  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes,
        [Map<String, Object?>? args]) async {
      final safeName =
          screenshotName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '-');
      final imageFile =
          File(screenshotsDirectory.path + '/$safeName.png');
      await imageFile.writeAsBytes(screenshotBytes, flush: true);
      return imageFile.existsSync() && imageFile.lengthSync() > 0;
    },
  );
}
