import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aura/core/di/injection.dart';
import 'package:aura/core/theme/app_theme.dart';
import 'package:aura/core/widgets/tob_bar.dart';
import 'package:aura/features/main_wrapper.dart';
import 'package:aura/features/music_player/presentation/manager/player_bloc.dart';
import 'package:aura/features/settings/presentation/manager/theme_cubit.dart';
import 'package:aura/features/splash/presentation/splash_screen.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:aura/core/models/media_item_adapter.dart';
import 'package:aura/features/music_player/domain/models/custom_queue_adapter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(MediaItemAdapter());
  Hive.registerAdapter(CustomQueueAdapter());

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
        BlocProvider(create: (_) => getIt<ThemeCubit>()),
        BlocProvider(create: (_) => NavigationCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Aura - Music Player',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const Scaffold(body: MainWrapperPage(index: 0)),
          );
        },
      ),
    );
  }
}
