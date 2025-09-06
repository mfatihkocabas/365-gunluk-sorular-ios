import SwiftUI
import UserNotifications

@main
struct DailyQuestionsApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .onAppear {
                    setupApp()
                }
        }
    }
    
    private func setupApp() {
        // Bildirim izinlerini iste
        NotificationManager.shared.requestPermission()
        
        // Eski bildirimleri temizle
        NotificationManager.shared.cleanupOldNotifications()
        
        // App açıldığında günün sorusunu yükle
        QuestionDataManager.shared.getQuestion(for: Calendar.current.dayOfYear(for: Date()) ?? 1)
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Notification Center delegate'ini ayarla
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // MARK: - Notification Delegate Methods
    
    // Uygulama foreground'dayken bildirim gelirse
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Bildirimi göster
        completionHandler([.banner, .badge, .sound])
    }
    
    // Bildirme tıklandığında
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        // Bildirimden gelen questionId'yi al
        if let questionId = NotificationManager.shared.handleNotificationTap(with: userInfo) {
            print("Bildirimden tıklandı - Soru ID: \(questionId)")
            
            // Ana ekrana yönlendir ve ilgili soruyu göster
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("ShowQuestionFromNotification"),
                    object: nil,
                    userInfo: ["questionId": questionId]
                )
            }
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let showQuestionFromNotification = Notification.Name("ShowQuestionFromNotification")
    static let themeChanged = Notification.Name("ThemeChanged")
    static let dataExported = Notification.Name("DataExported")
}
