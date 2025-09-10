import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingAboutSheet = false
    @State private var showingTutorial = false
    
    var body: some View {
        NavigationView {
            List {
                // Profil Bölümü
                ProfileSection()
                
                // Bildirimler
                NotificationSection(viewModel: viewModel)
                
                // Uygulama Bilgileri
                AppInfoSection(showingAboutSheet: $showingAboutSheet, showingTutorial: $showingTutorial)
                
                // Basit Ayarlar
                SimpleSettingsSection(viewModel: viewModel)
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAboutSheet) {
                AboutSheet()
            }
            .fullScreenCover(isPresented: $showingTutorial) {
                TutorialView(isPresented: $showingTutorial)
            }
        }
    }
}

// MARK: - Profile Section
struct ProfileSection: View {
    var body: some View {
        Section("Profil") {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.accent)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kullanıcı")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Text("Günlük düşünce yazarı")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
        }
    }
}

// MARK: - Simple Settings Section
struct SimpleSettingsSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section("Ayarlar") {
            SettingsRow(
                icon: "textformat.size",
                title: "Yazı Boyutu",
                subtitle: viewModel.fontSizeDescription,
                color: .brown
            ) {
                viewModel.showFontSizePicker()
            }
            
            SettingsRow(
                icon: "trash",
                title: "Tüm Verileri Sil",
                subtitle: "Dikkat: Bu işlem geri alınamaz",
                color: .red
            ) {
                viewModel.showDeleteAllAlert()
            }
        }
    }
}

// MARK: - Notification Section
struct NotificationSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section("Bildirimler") {
            SettingsRow(
                icon: "bell",
                title: "Bildirimler",
                subtitle: "Favori sorular için hatırlatma bildirimleri",
                color: .orange
            ) {
                viewModel.toggleNotifications()
            }
            .overlay(
                HStack {
                    Spacer()
                    Toggle("", isOn: $viewModel.isNotificationsEnabled)
                        .labelsHidden()
                }
            )
            
            if viewModel.isNotificationsEnabled {
                SettingsRow(
                    icon: "clock",
                    title: "Bildirim Zamanı",
                    subtitle: DateFormatter.timeFormatter.string(from: viewModel.notificationTime),
                    color: .purple
                ) {
                    viewModel.showTimePicker()
                }
                
                SettingsRow(
                    icon: "list.bullet",
                    title: "Bekleyen Bildirimler",
                    subtitle: "\(viewModel.pendingNotificationsCount) bildirim bekliyor",
                    color: .cyan
                ) {
                    viewModel.showPendingNotifications()
                }
            }
        }
    }
}

// MARK: - App Info Section
struct AppInfoSection: View {
    @Binding var showingAboutSheet: Bool
    @Binding var showingTutorial: Bool
    
    var body: some View {
        Section("Uygulama") {
            SettingsRow(
                icon: "info.circle",
                title: "Hakkında",
                subtitle: "Sürüm 1.0.0",
                color: .blue
            ) {
                showingAboutSheet = true
            }
            
            SettingsRow(
                icon: "questionmark.circle",
                title: "Nasıl Kullanılır?",
                subtitle: "Tutorial'ı tekrar izleyin",
                color: .green
            ) {
                showingTutorial = true
            }
            
            SettingsRow(
                icon: "star",
                title: "Uygulamayı Değerlendir",
                subtitle: "App Store'da değerlendirin",
                color: .yellow
            ) {
                // App Store değerlendirme sayfasını açma kodu buraya
            }
            
            SettingsRow(
                icon: "envelope",
                title: "Geri Bildirim Gönder",
                subtitle: "Önerilerinizi paylaşın",
                color: .purple
            ) {
                // Mail gönderme kodu buraya
            }
        }
    }
}


// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 24, height: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)
                        .foregroundColor(.primaryText)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - About Sheet
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App Icon
                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                        .padding(.top, 40)
                    
                    // App Info
                    VStack(spacing: 8) {
                        Text("365 Günlük Sorular")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("Sürüm 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Description
                    VStack(spacing: 16) {
                        Text("Her gün bir soru ile düşüncelerinizi kaydedin ve bir yıl sonra nasıl değiştiğinizi görün. Kişisel gelişim yolculuğunuzda yanınızdayız.")
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Text("Bu uygulama ile:")
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.top)
                    }
                    
                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "calendar", title: "365 Benzersiz Soru", description: "Her gün için özel olarak hazırlanmış sorular")
                        FeatureRow(icon: "heart.fill", title: "Favori Sorular", description: "Önemli soruları favorilere ekleyin ve 1 yıl sonra hatırlatma alın")
                        FeatureRow(icon: "clock.arrow.circlepath", title: "Zaman Kapsülü", description: "Geçmiş cevaplarınızı karşılaştırın ve değişiminizi görün")
                        FeatureRow(icon: "chart.bar.fill", title: "İstatistikler", description: "Cevaplarınızın analizi ve görselleştirmesi")
                        FeatureRow(icon: "lock.fill", title: "Güvenlik", description: "Tüm verileriniz cihazınızda güvenle saklanır")
                        FeatureRow(icon: "bell", title: "Akıllı Bildirimler", description: "Sadece favori sorularınız için 1 yıl sonra hatırlatma")
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // How it works
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Nasıl Çalışır?")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HowItWorksStep(number: "1", title: "Günlük Soru", description: "Her gün uygulamayı açın ve o günün sorusunu görün")
                            HowItWorksStep(number: "2", title: "Cevabınızı Yazın", description: "Düşüncelerinizi, duygularınızı ve deneyimlerinizi kaydedin")
                            HowItWorksStep(number: "3", title: "Favori Ekleyin", description: "Önemli soruları favorilere ekleyin (isteğe bağlı)")
                            HowItWorksStep(number: "4", title: "Zaman Kapsülü", description: "1 yıl sonra aynı soruyu tekrar görün ve değişiminizi fark edin")
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Privacy
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gizlilik ve Güvenlik")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text("• Tüm verileriniz sadece cihazınızda saklanır")
                        Text("• Hiçbir veri internet üzerinden gönderilmez")
                        Text("• Verileriniz tamamen size aittir")
                        Text("• Uygulama silindiğinde tüm veriler silinir")
                    }
                    .font(.body)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Developer Info
                    VStack(spacing: 8) {
                        Text("❤️ ile geliştirildi")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Text("© 2024 Günlük Sorular")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            .navigationTitle("Hakkında")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Kapat") { dismiss() })
        }
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

// MARK: - How It Works Step
struct HowItWorksStep: View {
    let number: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color(red: 1.0, green: 0.27, blue: 0.27))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
    }
}

// MARK: - Settings ViewModel
class SettingsViewModel: ObservableObject {
    @Published var isNotificationsEnabled = true
    @Published var notificationTime = Date()
    @Published var pendingNotificationsCount = 0
    @Published var fontSize: CGFloat = 16
    
    private let dataManager = DataManager.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        loadSettings()
        updatePendingNotificationsCount()
    }
    
    func loadSettings() {
        // UserDefaults'tan ayarları yükle
        isNotificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
        
        if let timeData = UserDefaults.standard.object(forKey: "notification_time") as? Date {
            notificationTime = timeData
        }
        
        fontSize = UserDefaults.standard.object(forKey: "font_size") as? CGFloat ?? 16
    }
    
    func saveSettings() {
        UserDefaults.standard.set(isNotificationsEnabled, forKey: "notifications_enabled")
        UserDefaults.standard.set(notificationTime, forKey: "notification_time")
        UserDefaults.standard.set(fontSize, forKey: "font_size")
    }
    
    func toggleNotifications() {
        isNotificationsEnabled.toggle()
        saveSettings()
        
        if isNotificationsEnabled {
            notificationManager.requestPermission()
        }
    }
    
    func showDeleteAllAlert() {
        // Alert gösterme implementasyonu
    }
    
    func showTimePicker() {
        // Time picker gösterme implementasyonu
    }
    
    func showPendingNotifications() {
        notificationManager.listPendingNotifications()
    }
    
    func showFontSizePicker() {
        // Font size picker implementasyonu
    }
    
    func updatePendingNotificationsCount() {
        // Bekleyen bildirim sayısını güncelle
    }
    
    var fontSizeDescription: String {
        switch fontSize {
        case ..<14: return "Küçük"
        case 14..<18: return "Normal"
        case 18..<22: return "Büyük"
        default: return "Çok Büyük"
        }
    }
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
