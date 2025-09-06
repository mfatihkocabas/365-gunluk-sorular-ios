import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingExportSheet = false
    @State private var showingAboutSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // Profil Bölümü
                ProfileSection()
                
                // Veri Yönetimi
                DataManagementSection(
                    viewModel: viewModel,
                    showingExportSheet: $showingExportSheet
                )
                
                // Bildirimler
                NotificationSection(viewModel: viewModel)
                
                // Uygulama Bilgileri
                AppInfoSection(showingAboutSheet: $showingAboutSheet)
                
                // Gelişmiş Ayarlar
                AdvancedSection(viewModel: viewModel)
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingExportSheet) {
                ExportDataSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showingAboutSheet) {
                AboutSheet()
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

// MARK: - Data Management Section
struct DataManagementSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Binding var showingExportSheet: Bool
    
    var body: some View {
        Section("Veri Yönetimi") {
            SettingsRow(
                icon: "square.and.arrow.up",
                title: "Verileri Dışa Aktar",
                subtitle: "Cevaplarınızı PDF veya metin olarak kaydedin",
                color: .blue
            ) {
                showingExportSheet = true
            }
            
            SettingsRow(
                icon: "icloud.and.arrow.up",
                title: "iCloud Yedekleme",
                subtitle: "Verilerinizi iCloud'a yedekleyin",
                color: .green
            ) {
                viewModel.toggleiCloudSync()
            }
            .overlay(
                HStack {
                    Spacer()
                    Toggle("", isOn: $viewModel.isiCloudSyncEnabled)
                        .labelsHidden()
                }
            )
            
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
                color: .green
            ) {
                // Mail gönderme kodu buraya
            }
        }
    }
}

// MARK: - Advanced Section
struct AdvancedSection: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        Section("Gelişmiş") {
            SettingsRow(
                icon: "paintbrush",
                title: "Karanlık Mod",
                subtitle: "Görünüm temasını değiştirin",
                color: .indigo
            ) {
                viewModel.toggleDarkMode()
            }
            .overlay(
                HStack {
                    Spacer()
                    Toggle("", isOn: $viewModel.isDarkModeEnabled)
                        .labelsHidden()
                }
            )
            
            SettingsRow(
                icon: "textformat.size",
                title: "Yazı Boyutu",
                subtitle: viewModel.fontSizeDescription,
                color: .brown
            ) {
                viewModel.showFontSizePicker()
            }
            
            SettingsRow(
                icon: "gear",
                title: "Gelişmiş Ayarlar",
                subtitle: "Debug ve test seçenekleri",
                color: .gray
            ) {
                viewModel.showAdvancedSettings()
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

// MARK: - Export Data Sheet
struct ExportDataSheet: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 60))
                    .foregroundColor(.accent)
                    .padding(.top, 40)
                
                Text("Verilerinizi Dışa Aktarın")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primaryText)
                
                Text("Cevaplarınızı farklı formatlarda dışa aktarabilirsiniz")
                    .font(.body)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    ExportOptionButton(
                        title: "PDF Olarak Dışa Aktar",
                        subtitle: "Güzel formatlanmış PDF dosyası",
                        icon: "doc.richtext",
                        color: .red
                    ) {
                        viewModel.exportAsPDF()
                    }
                    
                    ExportOptionButton(
                        title: "Metin Dosyası Olarak Dışa Aktar",
                        subtitle: "Düz metin formatında",
                        icon: "doc.text",
                        color: .blue
                    ) {
                        viewModel.exportAsText()
                    }
                    
                    ExportOptionButton(
                        title: "JSON Olarak Dışa Aktar",
                        subtitle: "Geliştiriciler için",
                        icon: "doc.plaintext",
                        color: .green
                    ) {
                        viewModel.exportAsJSON()
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Dışa Aktarma")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Kapat") { dismiss() })
        }
    }
}

// MARK: - Export Option Button
struct ExportOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondaryText)
            }
            .padding()
            .cardStyle()
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
                        .foregroundColor(.accent)
                        .padding(.top, 40)
                    
                    // App Info
                    VStack(spacing: 8) {
                        Text("365 Günlük Sorular")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primaryText)
                        
                        Text("Sürüm 1.0.0")
                            .font(.subheadline)
                            .foregroundColor(.secondaryText)
                    }
                    
                    // Description
                    Text("Her gün bir soru ile düşüncelerinizi kaydedin ve bir yıl sonra nasıl değiştiğinizi görün. Kişisel gelişim yolculuğunuzda yanınızdayız.")
                        .font(.body)
                        .foregroundColor(.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        FeatureRow(icon: "calendar", title: "365 Benzersiz Soru")
                        FeatureRow(icon: "heart.fill", title: "Favori Sorular ve Hatırlatmalar")
                        FeatureRow(icon: "clock.arrow.circlepath", title: "Geçmiş Karşılaştırma")
                        FeatureRow(icon: "chart.bar.fill", title: "İstatistikler ve Analizler")
                        FeatureRow(icon: "lock.fill", title: "Verileriniz Güvende")
                    }
                    .padding()
                    .cardStyle()
                    
                    // Developer Info
                    VStack(spacing: 8) {
                        Text("❤️ ile geliştirildi")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                        
                        Text("© 2024 Günlük Sorular")
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
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
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accent)
                .frame(width: 24)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primaryText)
            
            Spacer()
        }
    }
}

// MARK: - Settings ViewModel
class SettingsViewModel: ObservableObject {
    @Published var isNotificationsEnabled = true
    @Published var isiCloudSyncEnabled = false
    @Published var isDarkModeEnabled = false
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
        isiCloudSyncEnabled = UserDefaults.standard.bool(forKey: "icloud_sync_enabled")
        isDarkModeEnabled = UserDefaults.standard.bool(forKey: "dark_mode_enabled")
        
        if let timeData = UserDefaults.standard.object(forKey: "notification_time") as? Date {
            notificationTime = timeData
        }
        
        fontSize = UserDefaults.standard.object(forKey: "font_size") as? CGFloat ?? 16
    }
    
    func saveSettings() {
        UserDefaults.standard.set(isNotificationsEnabled, forKey: "notifications_enabled")
        UserDefaults.standard.set(isiCloudSyncEnabled, forKey: "icloud_sync_enabled")
        UserDefaults.standard.set(isDarkModeEnabled, forKey: "dark_mode_enabled")
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
    
    func toggleiCloudSync() {
        isiCloudSyncEnabled.toggle()
        saveSettings()
        // iCloud sync implementasyonu buraya
    }
    
    func toggleDarkMode() {
        isDarkModeEnabled.toggle()
        saveSettings()
        // Dark mode implementasyonu buraya
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
    
    func showAdvancedSettings() {
        // Advanced settings implementasyonu
    }
    
    func updatePendingNotificationsCount() {
        // Bekleyen bildirim sayısını güncelle
    }
    
    // Export functions
    func exportAsPDF() {
        let answers = dataManager.getAnswersForYear(Calendar.current.component(.year, from: Date()))
        // PDF export implementasyonu
        print("PDF export başlatıldı: \(answers.count) cevap")
    }
    
    func exportAsText() {
        let answers = dataManager.getAnswersForYear(Calendar.current.component(.year, from: Date()))
        // Text export implementasyonu
        print("Text export başlatıldı: \(answers.count) cevap")
    }
    
    func exportAsJSON() {
        let answers = dataManager.getAnswersForYear(Calendar.current.component(.year, from: Date()))
        // JSON export implementasyonu
        print("JSON export başlatıldı: \(answers.count) cevap")
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
