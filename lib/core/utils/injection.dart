import '../constants/api_constants.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../network/dio_client.dart';
import '../services/token_storage_service.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/bloc/login_bloc.dart';
import '../../features/dashboard/bloc/dashboard_bloc.dart';
import 'ocr_service.dart';
import 'ai_service.dart';
import 'excel_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features
  sl.registerFactory(() => AuthBloc(sl(), sl()));
  sl.registerFactory(() => LoginBloc(sl()));
  sl.registerFactory(() => DashboardBloc(repository: sl()));

  // Data sources

  // Repositories
  sl.registerLazySingleton<ContactRepository>(() => ContactRepository(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(sl(), sl()));

  // Services
  sl.registerLazySingleton(() => OCRService());
  sl.registerLazySingleton(() => AIService());
  sl.registerLazySingleton(() => ExcelService());
  sl.registerLazySingleton(
    () => TokenStorageService(const FlutterSecureStorage()),
  );

  // Core
  sl.registerLazySingleton(
    () => DioClient(baseUrl: ApiConstants.baseUrl, tokenService: sl()),
  );
}
