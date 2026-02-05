import 'package:aura/presentation/pages/main_wrapper_page.dart';
import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/di/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة قاعدة البيانات Hive
  await Hive.initFlutter();

  // تهيئة حقن التبعيات Service Locator
  await setupServiceLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // نستخدم MultiBlocProvider هنا لاحقاً لإضافة الـ Blocs العامة
    return MaterialApp(
      title: 'Aura - Music Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      home: const Scaffold(body: MainWrapperPage()),
    );
  }
}