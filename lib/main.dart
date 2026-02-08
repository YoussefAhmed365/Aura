import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'features/music_player/presentation/manager/player_bloc.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'features/main_wrapper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppStart());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Request "GetIt" to give a copy of "Bloc"
        BlocProvider(create: (_) => getIt<PlayerBloc>()),
      ],
      child: MaterialApp(
        title: 'Aura - Music Player',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,

        home: const Scaffold(body: MainWrapperPage()),
      ),
    );
  }
}
