import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/app_state.dart';
import 'core/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Storage.init();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState()..bootstrap(),
      child: const ArindiApp(),
    ),
  );
}
