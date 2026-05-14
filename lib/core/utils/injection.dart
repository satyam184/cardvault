import 'package:get_it/get_it.dart';
import 'ocr_service.dart';
import 'ai_service.dart';
import 'excel_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features
  
  // Data sources
  
  // Repositories
  
  // Services
  sl.registerLazySingleton(() => OCRService());
  sl.registerLazySingleton(() => AIService());
  sl.registerLazySingleton(() => ExcelService());
  
  // Core
}
