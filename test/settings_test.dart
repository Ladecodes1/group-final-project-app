import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:studylink/features/settings/data/settings_repository_impl.dart';
import 'package:studylink/features/settings/domain/app_settings.dart';
import 'package:studylink/features/settings/presentation/cubit/settings_cubit.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('defaults when nothing is saved', () async {
    final repo = SettingsRepositoryImpl(await SharedPreferences.getInstance());
    expect(repo.load(), const AppSettings());
  });

}
