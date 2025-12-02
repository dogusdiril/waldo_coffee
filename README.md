# ☕ Waldo Coffee - Görev Yönetim Sistemi

> Kafe ekipleri için akıllı görev takibi ve yönetimi

---

## 🎯 Özellikler

- ✅ Admin & Çalışan panelleri
- 📋 Görev oluşturma, atama, tamamlama
- 🚨 Acil görev bildirimleri
- 📊 Çalışan performans istatistikleri
- 🔐 Admin onay sistemi
- ☁️ Gerçek zamanlı senkronizasyon (Supabase)

---

## 🚀 Hızlı Başlangıç

### Yöntem 1: Docker ile (Kolay!)

```bash
# Docker Desktop kurulu olmalı
docker-compose up

# Tarayıcıda aç:
http://localhost:8080
```

### Yöntem 2: Flutter ile (Önerilen)

```bash
# Flutter kurulu olmalı (https://flutter.dev)
flutter pub get
flutter run -d chrome
```

---

## 📋 Gereksinimler

### Docker ile:
- ✅ Docker Desktop
- ✅ 8GB RAM
- ✅ 10GB Disk

### Flutter ile:
- ✅ Flutter SDK 3.19+
- ✅ Dart 3.0+
- ✅ Chrome / Android Emulator

---

## ⚙️ Kurulum (Flutter)

### 1. Proje Klasörüne Git
```bash
cd waldo_coffee
```

### 2. Bağımlılıkları İndir
```bash
flutter pub get
```

### 3. Supabase Ayarları

`lib/core/constants/app_constants.dart` dosyasında:
- `supabaseUrl` → Kendi Supabase URL'in
- `supabaseAnonKey` → Kendi anon key'in

(Veya bizim test ortamını kullan, zaten ayarlı!)

### 4. Çalıştır

**Web:**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run -d <emulator_id>
```

**Windows:**
```bash
flutter run -d windows
```

---

## 🗄️ Database Kurulumu

### Supabase'de:

1. **SQL Editor**'ı aç
2. `supabase_schema.sql` dosyasını kopyala
3. **Run** butonuna bas
4. İlk admin kullanıcıyı oluştur:

```sql
-- Authentication > Users'dan kullanıcı oluştur, sonra:
UPDATE public.profiles 
SET role = 'admin', is_approved = true 
WHERE email = 'ADMIN_EMAIL@example.com';
```

---

## 👥 Kullanıcı Rolleri

### Admin:
- ✅ Görev oluşturma
- ✅ Görev silme
- ✅ Çalışan onaylama
- ✅ İstatistikleri görme
- ✅ Tüm görevleri görme

### Çalışan:
- ✅ Görev alma
- ✅ Görev tamamlama
- ✅ Kendi görevlerini görme

---

## 📱 Release Build

### Android APK:
```bash
flutter build apk --release
# build/app/outputs/flutter-apk/app-release.apk
```

### Android Bundle (Play Store):
```bash
flutter build appbundle --release
# build/app/outputs/bundle/release/app-release.aab
```

### iOS:
```bash
flutter build ipa --release
# build/ios/archive/Runner.xcarchive
```


---

## 🐳 Docker Komutları

```bash
# Başlat
docker-compose up

# Arka planda başlat
docker-compose up -d

# Durdur
docker-compose down

# Yeniden build et
docker-compose up --build

# Container içine gir
docker exec -it waldo_coffee_dev bash

# Logları izle
docker-compose logs -f
```

---

## 📁 Proje Yapısı

```
waldo_coffee/
├── lib/
│   ├── main.dart              # Ana giriş
│   ├── config/                # Router
│   ├── core/                  # Models, Services, Providers
│   │   ├── constants/         # App ayarları
│   │   ├── models/            # User, Task modelleri
│   │   ├── providers/         # State management
│   │   ├── services/          # Supabase servisi
│   │   ├── theme/             # UI tema
│   │   └── widgets/           # Ortak widgetlar
│   └── features/
│       ├── auth/              # Login, Register
│       ├── admin/             # Admin paneli
│       ├── employee/          # Çalışan paneli
│       └── shared/            # Ortak componentler
├── android/                   # Android config
├── ios/                       # iOS config
├── supabase_schema.sql        # Database şeması
├── Dockerfile                 # Docker config
├── docker-compose.yml         # Docker compose
└── README.md                  # Bu dosya
```

---

## 🔐 Güvenlik

### ⚠️ Production'a alırken:

1. **Supabase Keys'i değiştir**
   - `.env` dosyası kullan
   - `app_constants.dart` hardcoded'ları sil

2. **Row Level Security kontrol et**
   - Supabase policies aktif

3. **API Rate Limiting**
   - Supabase ayarlarından

---

## 🧪 Test

```bash
# Testleri çalıştır (TODO)
flutter test

# Integration test (TODO)
flutter drive --target=test_driver/app.dart
```

---

## 🤝 Katkıda Bulun

1. Fork et
2. Feature branch oluştur (`git checkout -b feature/amazing`)
3. Commit et (`git commit -m 'Add amazing feature'`)
4. Push et (`git push origin feature/amazing`)
5. Pull Request aç

---

## 📞 Destek

- **Email:** dogus@waldocoffee.com
- **GitHub Issues:** https://github.com/SENIN_GITHUB/waldo_coffee/issues

---

## 📝 Lisans

MIT License - İstediğin gibi kullan! 🎉

---

## 🙏 Teşekkürler

Made with 🌊 by Kai & Doğuş

---

## 🔥 Katkıda Bulunanlar

- **Doğuş Diril** - Proje sahibi & Lead Developer
- **Kai** - AI Pair Programmer 🌊

---

**Başarılar! Sorular olursa bize ulaş! ☕🚀**
