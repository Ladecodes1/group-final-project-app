import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StudyLinkApp());
}

class StudyLinkApp extends StatelessWidget {
  const StudyLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<AuthRepository>(
      create: (_) => AuthRepositoryImpl(),
      child: BlocProvider(
        create: (context) =>
            AuthBloc(authRepository: context.read<AuthRepository>()),
        child: MaterialApp(
          title: 'StudyLink',
          theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
          home: BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              switch (state.status) {
                case AuthStatus.unknown:
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                case AuthStatus.authenticated:
                  return const HomePage();
                case AuthStatus.unauthenticated:
                  return const LoginPage();
              }
            },
          ),
        ),
      ),
    );
  }
}
