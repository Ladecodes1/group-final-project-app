import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Navigation helpers shared by the main screens.
extension MainScreenNavigation on BuildContext {
  /// Opens one of the main screens (Home, Find, Sessions) on top of Home.
  ///
  /// `go()` alone replaces the whole screen stack, so the phone's Back button
  /// would close the app. Going to Home first and then pushing the screen keeps
  /// Home underneath, so Back returns to Home.
  void openMainScreen(String location) {
    final router = GoRouter.of(this);
    router.go('/home');
    if (location != '/home') router.push(location);
  }
}
