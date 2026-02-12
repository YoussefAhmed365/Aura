import 'package:aura/core/di/injection.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/main.dart';
import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AppStart extends StatefulWidget {
  const AppStart({super.key});

  @override
  State<AppStart> createState() => _AppStartState();
}

class _AppStartState extends State<AppStart> {
  bool _isInitialized = false;
  bool _isPermissionDenied = false;
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
        await _checkAndRequestPermissions();
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

  Future<void> _checkAndRequestPermissions() async {
    try {
      final onAudioQuery = getIt<OnAudioQuery>();
      bool hasPermission = await onAudioQuery.permissionsStatus();

      if (!hasPermission) {
        hasPermission = await onAudioQuery.permissionsRequest();
      }

      if (mounted) {
        setState(() {
          if (hasPermission) {
            _isInitialized = true;
            _isPermissionDenied = false;
          } else {
            _isPermissionDenied = true;
            _isInitialized = false;
          }
        });
      }
    } catch (e) {
      debugPrint("Permission Check Error: $e");
      if (mounted) {
        setState(() {
          _error = "Error checking permissions: $e";
        });
      }
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
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Error initializing app: $_error",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    if (_isPermissionDenied) {
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
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_off, size: 80, color: Colors.white70),
                      const SizedBox(height: 20),
                      const Text(
                        "Permission Required",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Storage permission is required to access your music library. Please grant permission to continue.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _checkAndRequestPermissions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text("Grant Permission"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
              const SafeArea(child: Center(child: CircularProgressIndicator(color: Colors.white))),
            ],
          ),
        ),
      );
    }

    return const MyApp();
  }
}
