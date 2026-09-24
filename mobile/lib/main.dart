import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';
import 'core/kitchen_theme.dart' show KT;
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: ZadnaApp()));
}

class ZadnaApp extends ConsumerWidget {
  const ZadnaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Zadna',
      debugShowCheckedModeBanner: false,
      theme: KT.build(),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}