import 'package:flutter/material.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/core/di/injection.dart';
import 'package:aura/main.dart';

class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await configureDependencies().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw "Initialization timed out. Check AudioService or Permissions.";
        },
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
      debugPrint("Initialization Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Scaffold(body: Center(child: Text("Error initializing app: $_error"))),
      );
    }

    if (!_isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Scaffold(
            body: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2E1C4E), Colors.black]),
                  ),
                ),

                // Page Content
                const SafeArea(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            )),
      );
    }

    return const MyApp();
  }
}
