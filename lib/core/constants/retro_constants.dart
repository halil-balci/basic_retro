class RetroConstants {
  // Retro kategorileri - tek yerden yönetim
  static const List<String> categories = [
    'Sad',
    'Mad', 
    'Glad',
  ];
  
  // Kategori başlıkları
  static Map<String, String> categoryTitles = {
    categories[0]: 'Sad',
    categories[1]: 'Mad',
    categories[2]: 'Glad',
  };
  
  // Kategori açıklamaları
  static Map<String, String> categoryDescriptions = {
    categories[0]: 'What is driving you crazy? ',
    categories[1]: 'What is disappointing you? ',
    categories[2]: 'What is making you happy? ',
  };
  
  // Kategori renkleri
  static Map<String, String> categoryColors = {
    categories[0]: 'green',
    categories[1]: 'red',
    categories[2]: 'blue',
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
