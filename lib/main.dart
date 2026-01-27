import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TodoProvider(),
      child: const AcePickApp(),
    ),
  );
}

class AcePickApp extends StatelessWidget {
  const AcePickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AcePick Todo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
