import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:aura/core/di/injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // Name of the initialization function to be generated
  preferRelativeImports: false, // Use package paths for generated imports
  asExtension: true, // Generate the initialization as an extension method
)
Future<void> configureDependencies() async => await getIt.init();
