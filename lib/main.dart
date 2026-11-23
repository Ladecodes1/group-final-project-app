import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Loaded before runApp so saved settings apply on the very first frame.
  final prefs = await SharedPreferences.getInstance();
  // StudyLinkApp (lib/app/app.dart) provides AuthBloc, SettingsCubit and
  // StudyLinkCubit, and the router that sends signed-out users to Sign In.
  runApp(StudyLinkApp(prefs: prefs));
}
