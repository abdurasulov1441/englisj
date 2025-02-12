import 'package:english/pages/home_screen.dart';
import 'package:english/services/firebase_streem.dart';
import 'package:go_router/go_router.dart';

abstract final class Routes {
  static const firebaseStream = '/firebaseStream';
  static const home = '/home';
  static const loginPage = '/loginPage';
}

String _initialLocation() {
  return Routes.firebaseStream;
}

Object? _initialExtra() {
  return Routes.home;
}

final router = GoRouter(
  initialLocation: _initialLocation(),
  initialExtra: _initialExtra(),
  routes: [
    GoRoute(
      path: Routes.firebaseStream,
      builder: (context, state) {
        return const FirebaseStream();
      },
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) {
        return HomeScreen();
      },
    ),
  ],
);
