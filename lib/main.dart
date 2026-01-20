import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:acepick/core/theme/app_theme.dart';
// import 'package:acepick/core/services/notification_service.dart';  // Android 빌드 호환성 문제로 임시 제거
import 'package:acepick/features/race/presentation/screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // 로컬 알림 서비스 초기화 (Android 빌드 호환성 문제로 임시 제거)
  // await NotificationService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AcePick - 경마 예측 앱',
      theme: getAppTheme(),
      home: const HomeScreen(),
    );
  }
}
