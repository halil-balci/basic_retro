# Migration Guide - Clean Architecture Refactoring

Bu döküman, projenin clean architecture'a geçişinde yapılan değişiklikleri ve kullanım örneklerini içermektedir.

## 🔄 Yapılan Değişiklikler

### 1. Klasör Yapısı Değişiklikleri

#### Eski Yapı
```
lib/
├── features/
│   └── retro/
│       ├── data/
│       │   └── firebase_retro_repository.dart
│       ├── domain/
│       │   ├── retro_session.dart
│       │   ├── retro_thought.dart
│       │   └── i_retro_repository.dart
│       └── presentation/
│           └── (views)
```

#### Yeni Yapı
```
lib/
├── core/                          # YENİ: Core utilities
│   ├── di/                        # Dependency injection
│   ├── error/                     # Error handling
│   ├── network/                   # Network layer (Dio)
│   ├── presentation/              # Shared UI components
│   └── usecase/                   # Base use case
│
├── features/
│   └── retro/
│       ├── data/
│       │   ├── datasources/       # YENİ: Firebase data source
│       │   ├── models/            # YENİ: Data models
│       │   └── repositories/      # YENİ: Repository implementations
│       │
│       ├── domain/
│       │   ├── entities/          # YENİ: Domain entities
│       │   ├── repositories/      # YENİ: Repository interfaces
│       │   └── usecases/          # YENİ: Business logic use cases
│       │
│       └── presentation/
│           └── (views)
```

### 2. Dependency Injection

#### Eski Kod (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => RetroViewModel(
            FirebaseRetroRepository(FirebaseFirestore.instance),
          ),
        ),
      ],
      child: MaterialApp(...),
    );
  }
}
```

#### Yeni Kod (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // YENİ: Dependency injection initialization
  await initializeDependencies();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          // YENİ: GetIt ile dependency injection
          create: (context) => getIt<RetroViewModel>(),
        ),
      ],
      child: MaterialApp(
        // YENİ: Responsive framework
        builder: (context, child) => ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
        ...
      ),
    );
  }
}
```

### 3. Repository Pattern

#### Eski Kod
```dart
class FirebaseRetroRepository implements IRetroRepository {
  final FirebaseFirestore _firestore;

  Future<RetroSession> createSession(String name, String creatorId, String creatorName) async {
    final sessionRef = _firestore.collection('retro_sessions').doc();
    final session = RetroSession(...);
    await sessionRef.set(session.toJson());
    return session;
  }
}
```

#### Yeni Kod

**Domain Layer (Interface)**
```dart
// domain/repositories/retro_repository.dart
abstract class RetroRepository {
  Future<RetroSession> createSession(String name, String creatorId, String creatorName);
  // ... other methods
}
```

**Data Layer (Data Source)**
```dart
// data/datasources/firebase_retro_datasource.dart
class FirebaseRetroDataSource {
  final FirebaseFirestore _firestore;

  Future<RetroSessionModel> createSession(String name, String creatorId, String creatorName) async {
    final sessionRef = _firestore.collection('retro_sessions').doc();
    final session = RetroSessionModel(...);
    await sessionRef.set(session.toJson());
    return session;
  }
}
```

**Data Layer (Repository Implementation)**
```dart
// data/repositories/retro_repository_impl.dart
class RetroRepositoryImpl implements RetroRepository {
  final FirebaseRetroDataSource _dataSource;

  @override
  Future<RetroSession> createSession(String name, String creatorId, String creatorName) async {
    final model = await _dataSource.createSession(name, creatorId, creatorName);
    return model.toEntity();  // Model'i Entity'ye dönüştür
  }
}
```

### 4. Use Cases

#### Eski Kod (ViewModel'de direkt repository kullanımı)
```dart
class RetroViewModel extends ChangeNotifier {
  final IRetroRepository _repository;

  Future<RetroSession?> createSession(String name) async {
    try {
      final session = await _repository.createSession(
        name,
        _currentUserId,
        _currentUserName,
      );
      return session;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
```

#### Yeni Kod (Use Case ile)
```dart
// domain/usecases/create_session_usecase.dart
class CreateSessionUseCase implements UseCase<RetroSession, CreateSessionParams> {
  final RetroRepository repository;

  CreateSessionUseCase(this.repository);

  @override
  Future<Either<Failure, RetroSession>> call(CreateSessionParams params) async {
    try {
      final session = await repository.createSession(
        params.name,
        params.creatorId,
        params.creatorName,
      );
      return Right(session);
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

class CreateSessionParams {
  final String name;
  final String creatorId;
  final String creatorName;

  CreateSessionParams({
    required this.name,
    required this.creatorId,
    required this.creatorName,
  });
}
```

**ViewModel'de Kullanımı**
```dart
class RetroViewModel extends ChangeNotifier {
  final CreateSessionUseCase _createSessionUseCase;

  Future<RetroSession?> createSession(String name) async {
    final result = await _createSessionUseCase(
      CreateSessionParams(
        name: name,
        creatorId: _currentUserId,
        creatorName: _currentUserName,
      ),
    );

    return result.fold(
      (failure) {
        print('Error: ${failure.message}');
        return null;
      },
      (session) => session,
    );
  }
}
```

### 5. Responsive Design

#### Eski Kod
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            'Title',
            style: TextStyle(fontSize: 32),
          ),
          // ...
        ],
      ),
    ),
  );
}
```

#### Yeni Kod
```dart
@override
Widget build(BuildContext context) {
  // YENİ: Responsive values
  final padding = context.responsivePadding;
  final titleSize = context.responsiveTitleSize;
  final fontSize = context.responsiveFontSize;

  return ResponsiveLayout(
    child: Scaffold(
      body: Padding(
        padding: EdgeInsets.all(padding),  // Ekran boyutuna göre dinamik
        child: Column(
          children: [
            Text(
              'Title',
              style: TextStyle(fontSize: titleSize),  // Responsive font
            ),
            // YENİ: Ekran tipine göre kontrol
            if (context.isDesktop)
              DesktopSpecificWidget()
            else if (context.isTablet)
              TabletSpecificWidget()
            else
              MobileSpecificWidget(),
          ],
        ),
      ),
    ),
  );
}
```

### 6. Network Layer (Dio)

#### Yeni Özellik: API İstekleri için Dio
```dart
// Dio client kullanımı
final dioClient = getIt<DioClient>();

// GET request
try {
  final response = await dioClient.get('/api/sessions');
  print('Data: ${response.data}');
} on DioException catch (e) {
  final networkException = NetworkExceptions.fromDioError(e);
  print('Error: ${networkException.message}');
}

// POST request
try {
  final response = await dioClient.post(
    '/api/sessions',
    data: {
      'name': 'New Session',
      'creator': 'user123',
    },
  );
  print('Created: ${response.data}');
} on DioException catch (e) {
  final networkException = NetworkExceptions.fromDioError(e);
  print('Error: ${networkException.message}');
}
```

## 📋 Migration Checklist

Mevcut kodu yeni yapıya geçirmek için:

- [ ] Domain entities'leri `domain/entities/` klasörüne taşıyın
- [ ] Repository interface'lerini `domain/repositories/` klasörüne taşıyın
- [ ] Data models oluşturun (`data/models/`)
- [ ] Data source sınıfları oluşturun (`data/datasources/`)
- [ ] Repository implementation'ları oluşturun (`data/repositories/`)
- [ ] Use case sınıfları oluşturun (`domain/usecases/`)
- [ ] Dependency injection'a kayıt edin (`core/di/injection.dart`)
- [ ] View'ları responsive yapın
- [ ] ViewModel'leri use case kullanacak şekilde güncelleyin

## 🎯 Avantajlar

### Clean Architecture
- ✅ **Testability**: Her katman bağımsız test edilebilir
- ✅ **Maintainability**: Kod organizasyonu net ve anlaşılır
- ✅ **Scalability**: Yeni özellikler eklemek kolay
- ✅ **Separation of Concerns**: Her katmanın sorumluluğu net

### Dio Network Layer
- ✅ **Interceptors**: Otomatik logging ve error handling
- ✅ **Timeout Management**: Request timeout yönetimi
- ✅ **Type Safety**: Strongly typed API responses
- ✅ **Error Handling**: Merkezi hata yönetimi

### Responsive Framework
- ✅ **Multi-Device Support**: Mobile, tablet, desktop desteği
- ✅ **Adaptive UI**: Ekran boyutuna göre otomatik uyum
- ✅ **Consistent Design**: Tüm ekranlarda tutarlı görünüm
- ✅ **Easy to Use**: Context extensions ile kolay kullanım

## 🔍 İpuçları

### 1. Yeni Use Case Ekleme
```dart
// 1. Use case sınıfını oluşturun
class MyNewUseCase implements UseCase<ReturnType, Params> {
  final MyRepository repository;
  
  MyNewUseCase(this.repository);
  
  @override
  Future<Either<Failure, ReturnType>> call(Params params) async {
    // Implementation
  }
}

// 2. Dependency injection'a ekleyin
getIt.registerLazySingleton(() => MyNewUseCase(getIt()));

// 3. ViewModel'de kullanın
final useCase = getIt<MyNewUseCase>();
```

### 2. Responsive Widget Oluşturma
```dart
Widget build(BuildContext context) {
  return ResponsiveLayout(
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (context.isMobile) {
          return MobileLayout();
        } else if (context.isTablet) {
          return TabletLayout();
        } else {
          return DesktopLayout();
        }
      },
    ),
  );
}
```

### 3. Error Handling
```dart
final result = await useCase.call(params);

result.fold(
  (failure) {
    // Handle different failure types
    if (failure is NetworkFailure) {
      showSnackBar('Network error: ${failure.message}');
    } else if (failure is ServerFailure) {
      showSnackBar('Server error: ${failure.message}');
    } else {
      showSnackBar('Error: ${failure.message}');
    }
  },
  (success) {
    // Handle success
    print('Success: $success');
  },
);
```

## 📚 Ek Kaynaklar

- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Dio Package Documentation](https://pub.dev/packages/dio)
- [Responsive Framework Documentation](https://pub.dev/packages/responsive_framework)
- [GetIt Package Documentation](https://pub.dev/packages/get_it)

## ❓ Sık Sorulan Sorular

**S: Neden bu kadar çok katman var?**
A: Her katman belirli bir sorumluluğa sahiptir. Bu, kodun test edilebilirliğini, bakımını ve ölçeklenebilirliğini artırır.

**S: Use case'ler gereksiz karmaşıklık yaratmıyor mu?**
A: Küçük projelerde ek karmaşıklık gibi görünebilir, ancak proje büyüdükçe iş mantığının merkezileştirilmesi büyük fayda sağlar.

**S: Dio'yu neden Firebase yerine kullanmalıyım?**
A: Firebase hala kullanılıyor. Dio, gelecekte REST API entegrasyonları için hazırlık amaçlı eklenmiştir.

**S: Responsive framework performansı etkiler mi?**
A: Minimal bir overhead var, ancak kullanıcı deneyimindeki iyileşme bunu telafi eder.

## 🚀 Sonraki Adımlar

1. Mevcut kodları yavaş yavaş yeni yapıya migrate edin
2. Her feature için unit test yazın
3. Integration testleri ekleyin
4. CI/CD pipeline'ını yapılandırın
5. Code review süreçlerini clean architecture prensiplerine göre güncelleyin
