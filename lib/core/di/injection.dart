import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // اسم الدالة التي سيتم توليدها
  preferRelativeImports: true, // استخدام مسارات نسبية
  asExtension: true, // جعل التهيئه كـ Extension
)
Future<void> configureDependencies() async => getIt.init();
