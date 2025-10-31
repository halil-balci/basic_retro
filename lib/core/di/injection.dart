import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../../features/retro/data/datasources/firebase_retro_datasource.dart';
import '../../features/retro/data/datasources/retro_api_datasource.dart';
import '../../features/retro/data/datasources/gemini_datasource.dart';
import '../../features/retro/data/repositories/retro_repository_impl.dart';
import '../../features/retro/data/repositories/gemini_repository_impl.dart';
import '../../features/retro/domain/repositories/retro_repository.dart';
import '../../features/retro/domain/repositories/gemini_repository.dart';
import '../../features/retro/domain/usecases/create_session_usecase.dart';
import '../../features/retro/domain/usecases/join_session_usecase.dart';
import '../../features/retro/domain/usecases/add_thought_usecase.dart';
import '../../features/retro/domain/usecases/update_phase_usecase.dart';
import '../../features/retro/domain/usecases/generate_action_item_usecase.dart';
import '../../features/retro/presentation/retro_view_model.dart';
import '../network/dio_client.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Core
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      baseUrl: 'https://api.example.com', // Replace with your actual API URL when available
    ),
  );

  // Firebase
  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // Data sources
  getIt.registerLazySingleton<FirebaseRetroDataSource>(
    () => FirebaseRetroDataSource(getIt()),
  );

  getIt.registerLazySingleton<RetroApiDataSource>(
    () => RetroApiDataSource(getIt()),
  );

  getIt.registerLazySingleton<GeminiDataSource>(
    () => GeminiDataSource(getIt()),
  );

  // Repositories
  getIt.registerLazySingleton<RetroRepository>(
    () => RetroRepositoryImpl(
      getIt<FirebaseRetroDataSource>(),
      getIt<RetroApiDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GeminiRepository>(
    () => GeminiRepositoryImpl(getIt()),
  );

  // Use cases
  getIt.registerLazySingleton(() => CreateSessionUseCase(getIt()));
  getIt.registerLazySingleton(() => JoinSessionUseCase(getIt()));
  getIt.registerLazySingleton(() => AddThoughtUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdatePhaseUseCase(getIt()));
  getIt.registerLazySingleton(() => GenerateActionItemUseCase(getIt()));

  // View models
  getIt.registerFactory(() => RetroViewModel(getIt()));
}
