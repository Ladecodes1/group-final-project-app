import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String status = 'Firebase connected';
  try {
    await Firebase.initializeApp();
  } catch (error) {
    status = 'Firebase error: $error';
  }
  runApp(StudyLinkApp(status: status));
}

class StudyLinkApp extends StatelessWidget {
  const StudyLinkApp({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('StudyLink\n\n$status', textAlign: TextAlign.center),
          ),
        ),
      ),
    );
  }
}