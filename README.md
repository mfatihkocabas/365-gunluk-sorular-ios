# 365 Günlük Sorular - iOS Uygulaması

Bu uygulama, kullanıcıların her gün bir soruyu cevapladığı ve bir yıl sonra aynı soruya verdikleri cevapları karşılaştırabildiği günlük düşünce uygulamasıdır.

## 🎯 Temel Özellikler

### 📅 Günlük Soru Sistemi
- Her gün için özel olarak hazırlanmış 365 adet benzersiz soru
- Otomatik olarak günün sorusunu gösterme
- Soru kategorileri: Öz düşünce, ilişkiler, hedefler, minnettarlık, yaratıcılık vb.

### ❤️ Favori Sorular ve Hatırlatmalar
- İstediğiniz soruları favorilere ekleme
- Favori sorular için tam 1 yıl sonra otomatik hatırlatma bildirimi
- Bildirim: "1 yıl önce bu soruya şunu yazmıştın, bugün ne düşünüyorsun?"

### 📖 Geçmiş Karşılaştırma
- Aynı soruya geçmiş yıllarda verdiğiniz cevapları görme
- Son 5 yılın cevaplarını karşılaştırma
- Duygu ve düşünce değişimini takip etme

### 📊 İstatistikler ve Analiz
- Yıllık cevap sayısı istatistikleri
- Aylık dağılım grafikleri
- Favori soru sayıları
- Tamamlama yüzdeleri

### 📱 Modern UI/UX
- SwiftUI ile oluşturulmuş modern arayüz
- Karanlık mod desteği
- SF Symbols kullanımı
- Türkçe dil desteği

## 🏗️ Teknik Mimari

### MVVM Pattern
```
├── Models/
│   ├── Question.swift       # Soru modeli
│   └── Answer.swift         # Cevap modeli
├── ViewModels/
│   └── MainViewModel.swift  # Ana ekran view model
├── Views/
│   ├── MainView.swift       # Ana tab view
│   ├── TodayView.swift      # Günün sorusu
│   ├── HistoryView.swift    # Geçmiş cevaplar
│   ├── CalendarView.swift   # Takvim görünümü
│   ├── FavoritesView.swift  # Favori sorular
│   └── SettingsView.swift   # Ayarlar
├── Services/
│   ├── QuestionDataManager.swift    # Soru yönetimi
│   ├── DataManager.swift           # Veri yönetimi
│   └── NotificationManager.swift   # Bildirim yönetimi
└── Core/
    ├── Extensions.swift     # Yardımcı uzantılar
    └── DataManager.swift    # CoreData yönetimi
```

### Veri Saklama
- **CoreData**: Kullanıcı cevaplarının local olarak saklanması
- **JSON**: 365 adet sorunun embedded olarak uygulamada bulunması
- **UserDefaults**: Uygulama ayarlarının saklanması

### Bildirim Sistemi
- **Local Notifications**: 1 yıllık gecikmeli hatırlatmalar
- **UNUserNotificationCenter**: iOS bildirim sistemi entegrasyonu
- **Custom scheduling**: Favori sorular için özel zamanlama

## 🎨 Özellikler Detayı

### 📝 Günlük Deneyim
1. Uygulama açılırken günün sorusu otomatik yüklenir
2. Kullanıcı cevabını yazabilir
3. Emoji ve duygu durumu ekleyebilir
4. İsteğe bağlı favorilere ekleyebilir
5. Geçmiş yıl cevaplarını görüntüleyebilir

### 📅 Takvim Görünümü
- Hangi günlerde cevap verildiğini görsel olarak gösterme
- Favori sorular özel işaretleme
- Ay ve yıl bazında navigasyon
- Seçilen günün detaylarını görüntüleme

### 💾 Veri Dışa Aktarma
- PDF formatında dışa aktarma
- Metin dosyası olarak kaydetme
- JSON formatında geliştirici dostu export
- iCloud yedekleme desteği

### 🔔 Akıllı Bildirimler
- Sadece favori sorular için bildirim
- 1 yıl gecikmeli zamanlama
- Bildirimden doğrudan ilgili soruya yönlendirme
- Kullanıcı tarafından kontrol edilebilir bildirim ayarları

## 🚀 Kurulum ve Çalıştırma

### Gereksinimler
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

### Kurulum Adımları
1. Projeyi klonlayın
```bash
git clone [repository-url]
cd mini_project2
```

2. Xcode ile açın
```bash
open DailyQuestions.xcodeproj
```

3. Build ve çalıştırın
- Target device seçin
- ⌘+R ile çalıştırın

### İlk Çalıştırma
1. Bildirim izni verilir
2. Günün sorusu otomatik yüklenir
3. İlk cevabınızı yazabilirsiniz
4. Favorilere ekleyerek 1 yıl sonra hatırlatma alabilirsiniz

## 📱 Ekran Görünümleri

### Ana Ekran (Today)
- Günün sorusu
- Cevap yazma alanı
- Emoji ve duygu seçimi
- Favorilere ekleme seçeneği
- Geçmiş cevapları görüntüleme

### Geçmiş (History)
- Yıl bazında filtreleme
- İstatistikler ve grafikler
- Cevap kartları listesi
- Arama ve filtreleme

### Takvim (Calendar)
- Görsel takvim görünümü
- Cevaplanan günlerin işaretlenmesi
- Favori soruların özel gösterimi
- Seçilen günün detayları

### Favoriler (Favorites)
- Favori soru listesi
- Hatırlatma durumu bilgileri
- Favori çıkarma seçeneği
- İstatistikler

### Ayarlar (Settings)
- Veri dışa aktarma
- Bildirim ayarları
- Tema değiştirme
- Uygulama bilgileri

## 🔄 Veri Akışı

1. **Soru Yükleme**: `QuestionDataManager` günün sorusunu JSON'dan yükler
2. **Cevap Yazma**: Kullanıcı cevapları `DataManager` ile CoreData'ya kaydedilir
3. **Favori Ekleme**: Favori sorular için `NotificationManager` 1 yıllık bildirim programlar
4. **Geçmiş Görüntüleme**: CoreData'dan geçmiş cevaplar çekilir ve karşılaştırma yapılır

## 🎯 Kullanıcı Senaryoları

### Senaryo 1: İlk Kez Kullanım
1. Uygulama açılır, bildirim izni istenir
2. Günün sorusu gösterilir
3. Kullanıcı cevabını yazar
4. Favorilere ekler
5. 1 yıl sonra bildirim alır

### Senaryo 2: Günlük Kullanım
1. Her gün uygulamayı açar
2. O günün sorusunu cevaplar
3. Geçmiş yıl cevaplarını kontrol eder
4. Duygu değişimini gözlemler

### Senaryo 3: Geçmiş İnceleme
1. Takvim görünümünden geçmiş günleri inceler
2. İstatistikleri kontrol eder
3. Favori sorularını gözden geçirir
4. Verilerini dışa aktarır

## 🔒 Güvenlik ve Gizlilik

- Tüm veriler cihaz içinde saklanır (offline)
- Backend sunucu kullanılmaz
- iCloud yedekleme isteğe bağlıdır
- Kullanıcı verileri üçüncü taraflarla paylaşılmaz

## 🔮 Gelecek Özellikler

- [ ] Apple Watch desteği
- [ ] Widget desteği
- [ ] Ses kayıt özelliği
- [ ] Fotoğraf ekleme
- [ ] Sosyal paylaşım
- [ ] Tema özelleştirme
- [ ] Yedekleme ve senkronizasyon

## 🤝 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun
3. Değişikliklerinizi commit edin
4. Branch'inizi push edin
5. Pull request oluşturun

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 📞 İletişim

Sorularınız için [developer@example.com](mailto:developer@example.com) adresinden bize ulaşabilirsiniz.

---

**365 Günlük Sorular** - Düşüncelerinizi keşfedin, gelişiminizi takip edin! 🌱
