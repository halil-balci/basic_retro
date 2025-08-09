class RetroConstants {
  // Retro kategorileri - tek yerden yönetim
  static const List<String> categories = [
    'Start',
    'Stop', 
    'Continue',
  ];
  
  // Kategori başlıkları
  static const Map<String, String> categoryTitles = {
    'Start': 'Start Doing',
    'Stop': 'Stop Doing',
    'Continue': 'Continue Doing',
  };
  
  // Kategori açıklamaları
  static const Map<String, String> categoryDescriptions = {
    'Start': 'What should we start doing?',
    'Stop': 'What should we stop doing?',
    'Continue': 'What should we continue doing?',
  };
  
  // Kategori renkleri
  static const Map<String, String> categoryColors = {
    'Start': 'green',
    'Stop': 'red',
    'Continue': 'blue',
  };
  
  // Boş kategori map'i oluşturma helper'ı
  static Map<String, List<T>> createEmptyCategoryMap<T>() {
    return Map.fromEntries(
      categories.map((category) => MapEntry(category, <T>[])),
    );
  }
  
  // Kategori doğrulama
  static bool isValidCategory(String category) {
    return categories.contains(category);
  }
}
