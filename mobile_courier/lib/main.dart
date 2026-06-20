import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'core/app_state.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/applications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.instance.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: const CourierApp(),
    ),
  );
}

class CourierApp extends StatelessWidget {
  const CourierApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return MaterialApp(
      title: 'Arindi Kuryer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: state.loading
          ? const _Splash()
          : (state.isLoggedIn ? const ApplicationsScreen() : const LoginScreen()),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_shipping, color: Colors.white, size: 80),
              SizedBox(height: 16),
              Text('Arindi Kuryer',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
}
