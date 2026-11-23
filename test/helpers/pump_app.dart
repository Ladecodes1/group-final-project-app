import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studylink/features/auth/presentation/bloc/auth_bloc.dart';

/// Shows [page] inside a MaterialApp with the given [bloc] provided,
/// the same way main.dart sets it up, but without Firebase.
Future<void> pumpWithBloc(
  WidgetTester tester,
  AuthBloc bloc,
  Widget page,
) async {
  await tester.pumpWidget(
    BlocProvider<AuthBloc>.value(
      value: bloc,
      child: MaterialApp(home: page),
    ),
  );
}
