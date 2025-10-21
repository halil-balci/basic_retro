# Basic Retro - Clean Architecture Refactoring

Bu proje, **Clean Architecture** prensipleri, **Dio** ile network yönetimi ve **Responsive Framework** ile responsive tasarım kullanılarak yeniden yapılandırılmıştır.

## 🏗️ Mimari Yapısı

Proje, Clean Architecture prensiplerine göre üç temel katmana ayrılmıştır:

### 1. Domain Layer (İş Mantığı Katmanı)
- **Entities**: Uygulamanın temel veri yapıları
  - `RetroSession`: Retro oturum bilgilerini temsil eder
  - `RetroThought`: Düşünce/not bilgilerini içerir
  - `ThoughtGroup`: Gruplandırılmış düşünceleri yönetir
  - `RetroPhase`: Retro fazlarını tanımlar

- **Repositories (Interfaces)**: Veri erişim sözleşmeleri
  - `RetroRepository`: Retro özellikleri için repository interface

- **Use Cases**: İş mantığı operasyonları
  - `CreateSessionUseCase`: Yeni oturum oluşturma
  - `JoinSessionUseCase`: Mevcut oturuma katılma
  - `AddThoughtUseCase`: Düşünce ekleme
  - `UpdatePhaseUseCase`: Faz güncelleme

### 2. Data Layer (Veri Katmanı)
- **Models**: Domain entities'lerin JSON serileştirilebilir versiyonları
  - `RetroSessionModel`
  - `RetroThoughtModel`
  - `ThoughtGroupModel`

- **Data Sources**: Veri kaynaklarına erişim
  - `FirebaseRetroDataSource`: Firebase ile veri operasyonları

- **Repositories (Implementations)**: Repository interface'lerinin implementasyonları
  - `RetroRepositoryImpl`: Firebase kullanarak veri yönetimi

### 3. Presentation Layer (Sunum Katmanı)
- **Pages**: Ekran bileşenleri
  - `WelcomeView`: Giriş ekranı (Responsive)
  - `RetroBoardView`: Ana retro panosu (Responsive)

- **Widgets**: Yeniden kullanılabilir UI bileşenleri
  - `EditingPhaseWidget`
  - `VotingPhaseWidget`
  - `GroupingPhaseWidget`
  - `DiscussPhaseWidget`
  - `FinishPhaseWidget`

- **ViewModels**: UI state yönetimi
  - `RetroViewModel`: Provider ile state management

## 🌐 Network Katmanı (Dio)

### Dio Client Özellikleri
- RESTful API istekleri için hazır
- Otomatik logging (debug mode)
- Error handling
- Request/Response interceptors
- Timeout yönetimi

```dart
// Örnek kullanım
final dioClient = DioClient(
  baseUrl: 'https://api.example.com',
  connectTimeout: Duration(seconds: 30),
  receiveTimeout: Duration(seconds: 30),
);

// GET isteği
final response = await dioClient.get('/endpoint');

// POST isteği
final response = await dioClient.post('/endpoint', data: {...});
```

### Network Exception Handling
- Otomatik Dio error dönüşümü
- Anlaşılır hata mesajları
- HTTP status code yönetimi

## 📱 Responsive Design

### Responsive Framework Entegrasyonu
Proje, tüm ekranlarda responsive tasarım kullanır:

#### Breakpoints
- **Mobile**: 0-450px
- **Tablet**: 451-800px
- **Desktop**: 801-1920px
- **4K**: 1921px+

#### Responsive Utilities
```dart
// Context extensions
final padding = context.responsivePadding;      // Ekran boyutuna göre padding
final margin = context.responsiveMargin;        // Ekran boyutuna göre margin
final fontSize = context.responsiveFontSize;    // Ekran boyutuna göre font
final titleSize = context.responsiveTitleSize;  // Ekran boyutuna göre başlık

// Ekran tipi kontrolü
if (context.isMobile) { ... }
if (context.isTablet) { ... }
if (context.isDesktop) { ... }

// Responsive değerler
final value = ResponsiveLayout.getResponsiveValue<double>(
  context: context,
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);
```

### Responsive Layout Wrapper
Her ekran `ResponsiveLayout` widget'ı ile sarılmıştır ve otomatik olarak ekran boyutuna uyum sağlar.

## 🔧 Dependency Injection

### GetIt Kullanımı
Tüm bağımlılıklar `core/di/injection.dart` dosyasında merkezi olarak yönetilir:

```dart
// Servis lokasyonu
final viewModel = getIt<RetroViewModel>();
final repository = getIt<RetroRepository>();
final useCase = getIt<CreateSessionUseCase>();
```

### Kayıtlı Bağımlılıklar
- **Singleton**: DioClient, FirebaseFirestore, Repositories, UseCases
- **Factory**: ViewModels (her kullanımda yeni instance)

## 📂 Klasör Yapısı

```
lib/
├── core/
│   ├── di/
│   │   └── injection.dart              # Dependency injection
│   ├── error/
│   │   ├── failures.dart               # Hata sınıfları
│   │   └── network_exceptions.dart     # Network hata yönetimi
│   ├── network/
│   │   ├── dio_client.dart             # Dio HTTP client
│   │   └── api_response.dart           # API response wrapper
│   ├── presentation/
│   │   └── layouts/
│   │       └── responsive_layout.dart  # Responsive layout utils
│   └── usecase/
│       └── usecase.dart                # Base use case interface
│
├── features/
│   └── retro/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── firebase_retro_datasource.dart
│       │   ├── models/
│       │   │   ├── retro_session_model.dart
│       │   │   ├── retro_thought_model.dart
│       │   │   └── thought_group_model.dart
│       │   └── repositories/
│       │       └── retro_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── retro_session.dart
│       │   │   ├── retro_thought.dart
│       │   │   ├── thought_group.dart
│       │   │   └── retro_phase.dart
│       │   ├── repositories/
│       │   │   └── retro_repository.dart
│       │   └── usecases/
│       │       ├── create_session_usecase.dart
│       │       ├── join_session_usecase.dart
│       │       ├── add_thought_usecase.dart
│       │       └── update_phase_usecase.dart
│       │
│       └── presentation/
│           ├── pages/
│           │   ├── welcome_view.dart
│           │   └── retro_board_view.dart
│           ├── widgets/
│           │   ├── editing_phase_widget.dart
│           │   ├── voting_phase_widget.dart
│           │   ├── grouping_phase_widget.dart
│           │   ├── discuss_phase_widget.dart
│           │   └── finish_phase_widget.dart
│           └── retro_view_model.dart
│
└── main.dart
```

## 🚀 Kurulum ve Çalıştırma

### 1. Bağımlılıkları Yükleyin
```bash
flutter pub get
```

### 2. Firebase Yapılandırması
Firebase projenizi yapılandırın ve `firebase_options.dart` dosyasını güncelleyin.

### 3. Uygulamayı Çalıştırın
```bash
flutter run
```

## 📦 Kullanılan Paketler

### Core Packages
- **firebase_core**: ^2.15.1
- **cloud_firestore**: ^4.9.1
- **provider**: ^6.0.5

### Network
- **dio**: ^5.4.0

### Responsive Design
- **responsive_framework**: ^1.1.1

### Dependency Injection
- **get_it**: ^7.6.4

### Functional Programming
- **dartz**: ^0.10.1

### Code Generation
- **freezed_annotation**: ^2.4.1
- **json_annotation**: ^4.8.1
- **build_runner**: ^2.4.6
- **freezed**: ^2.4.5
- **json_serializable**: ^6.7.1

## 🎯 Clean Architecture Prensipleri

### 1. Separation of Concerns
Her katman kendi sorumluluğunu taşır ve diğer katmanlardan bağımsızdır.

### 2. Dependency Rule
Bağımlılıklar sadece içeri doğru işaret eder:
- Presentation → Domain ← Data
- Domain katmanı en içtedir ve hiçbir dış katmana bağımlı değildir

### 3. Testability
Her katman bağımsız olarak test edilebilir.

### 4. Maintainability
Kod organizasyonu sayesinde bakım ve güncelleme kolaydır.

## 🔄 Veri Akışı

```
UI (View) → ViewModel → UseCase → Repository (Interface) → Repository (Impl) → DataSource → Firebase
```

### Tersine Akış (Callback/Stream)
```
Firebase → DataSource → Repository (Impl) → Stream → ViewModel → UI güncellemesi
```

## 📝 Örnek Kullanım

### Yeni Oturum Oluşturma
```dart
// Use case üzerinden
final useCase = getIt<CreateSessionUseCase>();
final result = await useCase.call(
  CreateSessionParams(
    name: 'Sprint Planning',
    creatorId: 'user123',
    creatorName: 'John Doe',
  ),
);

result.fold(
  (failure) => print('Error: ${failure.message}'),
  (session) => print('Success: ${session.id}'),
);
```

### Responsive UI Oluşturma
```dart
@override
Widget build(BuildContext context) {
  final padding = context.responsivePadding;
  final fontSize = context.responsiveFontSize;
  
  return ResponsiveLayout(
    child: Padding(
      padding: EdgeInsets.all(padding),
      child: Text(
        'Responsive Text',
        style: TextStyle(fontSize: fontSize),
      ),
    ),
  );
}
```

## 🛠️ Geliştirme Notları

### Yeni Feature Ekleme
1. Domain layer'da entity ve repository interface oluşturun
2. Data layer'da model ve repository implementation ekleyin
3. Use case'leri tanımlayın
4. Presentation layer'da UI bileşenlerini oluşturun
5. Dependency injection'a ekleyin

### Testing
```bash
# Unit testler
flutter test

# Widget testler
flutter test test/widget_test.dart

# Integration testler
flutter test integration_test/
```

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👥 Katkıda Bulunma

Katkılarınızı bekliyoruz! Lütfen pull request göndermeden önce kod standartlarına uyduğunuzdan emin olun.

## 📞 İletişim

Sorularınız için issue açabilir veya pull request gönderebilirsiniz.
