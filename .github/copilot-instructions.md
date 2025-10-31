# Copilot Instructions for Basic Retro

## Project Overview
Flutter web application for agile retrospective meetings with Firebase backend. Implements **Clean Architecture** with three distinct layers: Domain, Data, and Presentation.

## Architecture Principles

### Layer Structure
```
Domain Layer (lib/features/retro/domain/)
  ├── entities/        - Core business objects (RetroSession, RetroThought, RetroPhase)
  ├── repositories/    - Repository interfaces only
  └── usecases/        - Business logic operations

Data Layer (lib/features/retro/data/)
  ├── datasources/     - Firebase operations (FirebaseRetroDataSource)
  ├── models/          - JSON-serializable data models
  └── repositories/    - Repository implementations

Presentation Layer (lib/features/retro/presentation/)
  ├── widgets/         - Reusable UI components per phase
  └── retro_view_model.dart - Provider-based state management
```

### Key Architectural Patterns
- **Use Cases**: All business logic operations inherit from `UseCase<Type, Params>` base class (see `lib/core/usecase/usecase.dart`)
- **Either Pattern**: Use `dartz` library's `Either<Failure, T>` for error handling in domain layer
- **Repository Pattern**: Domain defines interfaces, data layer implements them (e.g., `RetroRepository` interface → `RetroRepositoryImpl`)
- **Dependency Injection**: GetIt service locator in `lib/core/di/injection.dart` - all dependencies registered here

## State Management

### Provider Pattern
- `RetroViewModel` extends `ChangeNotifier` and is the single source of truth
- Registered as factory in DI: `getIt.registerFactory(() => RetroViewModel(getIt()))`
- Access via `Provider.of<RetroViewModel>(context)` or `context.watch<RetroViewModel>()`
- Always call `notifyListeners()` after state mutations

### Session Lifecycle
ViewModel manages web-specific session cleanup via `WebSessionService`:
- Registers sessions on join: `WebSessionService.registerSession(sessionId, userId)`
- Sends beacon on page unload for immediate Firebase cleanup
- Uses `dart:html` and `dart:js` for browser event interception

## Network Layer (Dio)

### Architecture Decision
**IMPORTANT**: All new external API calls MUST use Dio client. Legacy Firebase-only operations can remain direct, but any REST API, HTTP endpoint, or external service integration should use the Dio infrastructure.

### DioClient Setup
Located in `lib/core/network/dio_client.dart` with pre-configured:
- 30-second connection/receive timeouts
- JSON content-type headers
- Automatic request/response logging (debug mode)
- Error interceptors for unified error handling

### Registered in DI
```dart
// In lib/core/di/injection.dart
getIt.registerLazySingleton<DioClient>(
  () => DioClient(
    baseUrl: 'https://api.example.com', // Update with actual API URL
  ),
);
```

### Standard Usage Pattern
**For new DataSources**, inject DioClient and use it for HTTP operations:

```dart
class ExternalApiDataSource {
  final DioClient _dioClient;
  
  ExternalApiDataSource(this._dioClient);
  
  Future<SomeModel> fetchData(String id) async {
    try {
      final response = await _dioClient.get('/endpoint/$id');
      return SomeModel.fromJson(response.data);
    } on DioException catch (e) {
      final networkException = NetworkExceptions.fromDioError(e);
      throw networkException;
    }
  }
}
```

### Error Handling Pattern
Always wrap Dio calls with try-catch and convert to `NetworkExceptions`:

```dart
// In DataSource
try {
  final response = await _dioClient.post('/endpoint', data: payload);
  return ModelClass.fromJson(response.data);
} on DioException catch (e) {
  throw NetworkExceptions.fromDioError(e);
}

// In Repository Implementation
try {
  final model = await dataSource.fetchData(id);
  return Right(model.toEntity());
} on NetworkExceptions catch (e) {
  return Left(e.toFailure()); // Converts to ServerFailure/NetworkFailure
}
```

### Available Methods
- `get(path, {queryParameters, options, cancelToken})`
- `post(path, {data, queryParameters, options, cancelToken})`
- `put(path, {data, queryParameters, options, cancelToken})`
- `delete(path, {data, queryParameters, options, cancelToken})`
- `patch(path, {data, queryParameters, options, cancelToken})`

### ApiResponse Wrapper
Use `ApiResponse<T>` (in `lib/core/network/api_response.dart`) for structured API responses:

```dart
// For APIs that return standardized JSON structure
final response = await _dioClient.get('/endpoint');
final apiResponse = ApiResponse<UserModel>.fromJson(
  response.data,
  (json) => UserModel.fromJson(json),
);

if (apiResponse.success && apiResponse.data != null) {
  return Right(apiResponse.data!.toEntity());
}
```

### Migration Strategy
When refactoring existing code:
1. Keep Firebase Firestore operations as-is (already optimized)
2. Replace any raw `http` package calls with DioClient
3. For new features requiring external APIs, always use DioClient
4. Document base URL in DI registration when actual endpoint is added

### Complete Implementation Example

#### 1. Create DataSource with DioClient
```dart
// lib/features/retro/data/datasources/retro_api_datasource.dart
class RetroApiDataSource {
  final DioClient _dioClient;
  
  RetroApiDataSource(this._dioClient);
  
  Future<List<TemplateModel>> fetchRetroTemplates() async {
    try {
      final response = await _dioClient.get('/templates');
      return (response.data as List)
          .map((json) => TemplateModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }
  
  Future<ExportModel> exportSession(String sessionId) async {
    try {
      final response = await _dioClient.post(
        '/export',
        data: {'sessionId': sessionId},
      );
      return ExportModel.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }
}
```

#### 2. Update Repository Implementation
```dart
// In repository implementation
class RetroRepositoryImpl implements RetroRepository {
  final FirebaseRetroDataSource _firebaseDataSource;
  final RetroApiDataSource _apiDataSource; // NEW
  
  RetroRepositoryImpl(this._firebaseDataSource, this._apiDataSource);
  
  @override
  Future<Either<Failure, List<RetroTemplate>>> getTemplates() async {
    try {
      final models = await _apiDataSource.fetchRetroTemplates();
      return Right(models.map((m) => m.toEntity()).toList());
    } on NetworkExceptions catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}
```

#### 3. Register in DI Container
```dart
// In lib/core/di/injection.dart
Future<void> initializeDependencies() async {
  // Update DioClient with actual base URL when available
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(
      baseUrl: 'https://your-api-domain.com/api/v1',
    ),
  );
  
  // Register new API data source
  getIt.registerLazySingleton<RetroApiDataSource>(
    () => RetroApiDataSource(getIt()),
  );
  
  // Update repository with both data sources
  getIt.registerLazySingleton<RetroRepository>(
    () => RetroRepositoryImpl(getIt(), getIt()),
  );
  
  // ... rest of registrations
}
```

### Interceptor Customization
To add authentication or custom headers, modify `_setupInterceptors()` in `DioClient`:

```dart
void _setupInterceptors() {
  _dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if needed
        final token = getIt<AuthService>().token;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('REQUEST[${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      // ... existing onResponse and onError handlers
    ),
  );
}
```

## Firebase Integration

### Collections Structure
- `retro_sessions` - Main session documents
- `thoughts` - Subcollection under sessions
- `action_items` - Subcollection for post-retro actions

### Real-time Updates
Always use Firestore streams for live data:
```dart
Stream<RetroSessionModel?> getSessionStream(String sessionId) {
  return _firestore.collection(_sessionsCollection)
    .doc(sessionId)
    .snapshots()
    .map((doc) => doc.exists ? RetroSessionModel.fromJson({...doc.data()!, 'id': doc.id}) : null);
}
```

### Firebase vs Dio Decision Matrix
- **Use Firebase**: Real-time listeners, Firestore CRUD, authentication
- **Use Dio**: External REST APIs, third-party integrations, analytics APIs, export services

## Responsive Design

### Breakpoints (via responsive_framework)
- Mobile: 0-450px
- Tablet: 451-800px
- Desktop: 801-1920px
- 4K: 1921px+

### Context Extensions
Use these helpers from `lib/core/presentation/layouts/responsive_layout.dart`:
```dart
context.responsivePadding    // EdgeInsets based on screen size
context.responsiveMargin     // EdgeInsets.symmetric based on screen size
context.responsiveFontSize   // Double for body text
context.responsiveTitleSize  // Double for titles
context.isMobile             // Boolean check
```

## Retro Phase System

### Phase Flow
Enum in `lib/features/retro/domain/entities/retro_phase.dart`:
1. `editing` - Add thoughts to Sad/Mad/Glad categories
2. `grouping` - Drag-drop similar thoughts into groups
3. `voting` - Vote on groups (max 4 votes per user via `RetroConstants.maxVotesPerUser`)
4. `discuss` - Sequential discussion of voted groups
5. `finish` - Feedback and action items

### Phase-Specific Widgets
Each phase has dedicated widget in `lib/features/retro/presentation/widgets/`:
- `EditingPhaseWidget` - Category columns with thought cards
- `GroupingPhaseWidget` - Drag-drop grouping interface
- `VotingPhaseWidget` - Voting UI with vote limits
- `DiscussPhaseWidget` - Sequential group discussion
- `FinishPhaseWidget` - Feedback form and action item export

## Constants & Configuration

### Retro Categories
Centrally managed in `lib/core/constants/retro_constants.dart`:
```dart
RetroConstants.categories           // ['Sad', 'Mad', 'Glad']
RetroConstants.categoryTitles       // Display titles
RetroConstants.categoryDescriptions // Category prompts
RetroConstants.createEmptyCategoryMap<T>() // Helper for category-keyed maps
```

## Development Workflow

### Running the App
```bash
flutter pub get
flutter run -d chrome  # Web development
```

### Firebase Setup
1. Copy `lib/firebase_options.dart.template` to `lib/firebase_options.dart`
2. Replace placeholders with actual Firebase config
3. Never commit `firebase_options.dart` (gitignored)

### Code Generation
Not currently used (freezed/json_serializable declared in pubspec but not implemented). Models use manual JSON serialization.

## Common Patterns

### Adding a New Use Case
1. Create in `lib/features/retro/domain/usecases/`
2. Implement `UseCase<ReturnType, ParamsClass>`
3. Register in `lib/core/di/injection.dart` as lazy singleton
4. Inject into `RetroViewModel` constructor

### Adding External API Integration
When integrating a new external API:
1. **Create DataSource** in `lib/features/[feature]/data/datasources/` that uses DioClient
2. **Handle errors** by catching `DioException` and converting to `NetworkExceptions`
3. **Update Repository** to inject and use the new data source
4. **Register in DI** - add data source and update repository dependencies
5. **Create Use Case** if business logic is needed
6. **Update ViewModel** to call the use case

Example workflow:
```dart
// 1. DataSource
class ExternalDataSource {
  final DioClient _dioClient;
  ExternalDataSource(this._dioClient);
  
  Future<Model> fetch() async {
    try {
      final response = await _dioClient.get('/path');
      return Model.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkExceptions.fromDioError(e);
    }
  }
}

// 2. Repository adds method
@override
Future<Either<Failure, Entity>> fetchData() async {
  try {
    final model = await _externalDataSource.fetch();
    return Right(model.toEntity());
  } on NetworkExceptions catch (e) {
    return Left(e.toFailure());
  }
}

// 3. DI registration
getIt.registerLazySingleton<ExternalDataSource>(
  () => ExternalDataSource(getIt()),
);
```

### Error Handling
- Domain layer: Return `Either<Failure, T>`
- Presentation layer: Check `.isLeft()` or `.fold()` to display errors
- Failure types in `lib/core/error/failures.dart`: `ServerFailure`, `NetworkFailure`, `ValidationFailure`, `UnexpectedFailure`
- Network errors: Always catch `DioException` in data sources and convert to `NetworkExceptions`, then to `Failure` in repositories

### Web-Specific Concerns
- Use `kIsWeb` check before importing `dart:html` or `dart:js`
- Browser events handled in `WebSessionService` for session cleanup
- Beacon API used for unload events (synchronous cleanup)

## Key Files
- `lib/main.dart` - App entry, DI initialization, responsive config
- `lib/core/di/injection.dart` - Dependency graph definition
- `lib/features/retro/presentation/retro_view_model.dart` - Core state management (806 lines)
- `lib/features/retro/data/datasources/firebase_retro_datasource.dart` - Firebase operations
- `CLEAN_ARCHITECTURE_README.md` - Detailed architecture documentation
- `MIGRATION_GUIDE.md` - Legacy to clean architecture migration examples
