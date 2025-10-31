# 🚀 Hızlı Deployment Kılavuzu

## Otomatik Deployment (Önerilen)

### Tek Komutla Build + Deploy

```powershell
.\deploy.ps1
```

Bu komut:
1. ✅ `.env` dosyasından API key'i otomatik okur
2. ✅ Flutter web uygulamasını build eder
3. ✅ Firebase Hosting'e deploy eder

### Sadece Build (Deploy Sonra)

```powershell
.\build_web.ps1
```

Sonra manuel deploy:
```powershell
firebase deploy --only hosting
```

## Gereksinimler

### 1. .env Dosyası

Proje kök dizininde `.env` dosyanız olmalı:
```bash
GEMINI_API_KEY=your_actual_api_key_here
```

✅ Bu dosya zaten `.gitignore`'da, git'e commit edilmeyecek

### 2. Firebase CLI

Firebase CLI yüklü olmalı:
```powershell
npm install -g firebase-tools
firebase login
```

## Nasıl Çalışıyor?

1. **Script `.env` dosyasını okur**: `GEMINI_API_KEY` değerini bulur
2. **Build sırasında API key'i ekler**: `--dart-define=GEMINI_API_KEY=...`
3. **Web uygulaması build edilir**: `build/web/` klasörüne
4. **(deploy.ps1 için)** Firebase'e upload edilir

## Avantajlar

- ✅ Her seferinde API key yazmaya gerek yok
- ✅ API key güvende (gitignore'da)
- ✅ Tek komutla deploy
- ✅ Hata kontrolü var (API key yoksa uyarı verir)

## Sorun Giderme

### ".env file not found" Hatası

`.env` dosyası yoksa veya yanlış konumda. Çözüm:
```powershell
# Proje kök dizininde olduğunuzdan emin olun
cd "c:\Users\nisa umay\flutter_workspace\basic_retro\basic_retro"

# .env dosyası var mı kontrol edin
Test-Path .env

# Yoksa oluşturun
"GEMINI_API_KEY=your_api_key_here" | Out-File -FilePath .env -Encoding UTF8
```

### "GEMINI_API_KEY not found" Hatası

`.env` dosyasında API key eksik. Çözüm:
```powershell
# .env dosyasını düzenleyin
notepad .env

# Şu satırı ekleyin:
GEMINI_API_KEY=your_actual_api_key_here
```

### PowerShell Execution Policy Hatası

Script çalışmıyorsa:
```powershell
powershell -ExecutionPolicy Bypass -File .\deploy.ps1
```

## Local Development

Local development için:
```powershell
flutter run -d chrome --dart-define=GEMINI_API_KEY=$((Get-Content .env | Select-String "GEMINI_API_KEY").ToString().Split("=")[1])
```

Veya daha basit:
```powershell
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_actual_api_key_here
```

## Güvenlik Notları

- ✅ `.env` dosyası `.gitignore`'da - Git'e commit edilmeyecek
- ✅ API key sadece sizin bilgisayarınızda
- ⚠️ Build edilen dosyalarda API key görünür olacak (normal, client-side API)
- 🔒 Google Cloud Console'dan API key'i domain ile sınırlayın:
  1. https://console.cloud.google.com/apis/credentials
  2. API key'inizi seçin
  3. "Application restrictions" → "HTTP referrers"
  4. Firebase hosting domain'inizi ekleyin (örn: `your-app.web.app/*`)

## CI/CD için

GitHub Actions veya başka CI/CD kullanıyorsanız:

1. Repository secrets'a API key ekleyin
2. Workflow'da kullanın:

```yaml
- name: Build Flutter Web
  run: flutter build web --dart-define=GEMINI_API_KEY=${{ secrets.GEMINI_API_KEY }} --release
  
- name: Deploy to Firebase
  run: firebase deploy --only hosting --token ${{ secrets.FIREBASE_TOKEN }}
```
