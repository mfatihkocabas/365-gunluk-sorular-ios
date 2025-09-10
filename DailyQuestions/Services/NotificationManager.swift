import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        NSLog("🔔 DEBUG: Bildirim izni isteniyor...")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                NSLog("❌ DEBUG: Bildirim izni hatası: \(error)")
            }
            DispatchQueue.main.async {
                NSLog("✅ DEBUG: Bildirim izni verildi: \(granted)")
            }
        }
    }
    
    func scheduleOneYearReminder(for answer: Answer) {
        guard answer.isFavorite else { 
            NSLog("🔔 DEBUG: Bildirim ayarlanmadı - favori değil")
            return 
        }
        
        NSLog("🔔 DEBUG: Bildirim ayarlanıyor - Soru ID: \(answer.questionId)")
        
        // Bildirim izni kontrol et
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            NSLog("🔔 DEBUG: Bildirim izni durumu: \(settings.authorizationStatus.rawValue)")
            
            if settings.authorizationStatus == .notDetermined {
                NSLog("🔔 DEBUG: Bildirim izni isteniyor...")
                self.requestPermission()
            } else if settings.authorizationStatus == .denied {
                NSLog("❌ DEBUG: Bildirim izni reddedilmiş")
                return
            }
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Bir Yıl Önceki Düşüncen"
        content.body = "1 yıl önce bu soruya '\(answer.text.prefix(50))...' yazmıştın. Bugün ne düşünüyorsun?"
        content.sound = .default
        content.userInfo = [
            "questionId": answer.questionId,
            "originalDate": answer.date.timeIntervalSince1970
        ]
        
        // TEST İÇİN: 1 dakika sonra bildirim (normalde 1 yıl)
        let oneMinuteLater = Calendar.current.date(byAdding: .minute, value: 1, to: Date()) ?? Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneMinuteLater)
        
        NSLog("🔔 DEBUG: Bildirim tarihi: \(oneMinuteLater)")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "reminder_\(answer.questionId)_\(answer.date.timeIntervalSince1970)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                NSLog("❌ DEBUG: Bildirim hatası: \(error)")
            } else {
                NSLog("✅ DEBUG: Bildirim başarıyla ayarlandı - Soru ID: \(answer.questionId)")
            }
        }
    }
    
    func cancelReminder(for answer: Answer) {
        let identifier = "reminder_\(answer.questionId)_\(answer.date.timeIntervalSince1970)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func handleNotificationTap(with userInfo: [AnyHashable: Any]) -> Int? {
        guard let questionId = userInfo["questionId"] as? Int else { return nil }
        return questionId
    }
    
    // Tüm bekleyen bildirimleri listele (debug için)
    func listPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending notifications: \(requests.count)")
            for request in requests {
                print("- \(request.identifier): \(request.content.title)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("  Date: \(trigger.nextTriggerDate() ?? Date())")
                }
            }
        }
    }
    
    // Geçmiş bildirimleri temizle
    func cleanupOldNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let now = Date()
            let outdatedRequests = requests.filter { request in
                if let trigger = request.trigger as? UNCalendarNotificationTrigger,
                   let triggerDate = trigger.nextTriggerDate() {
                    return triggerDate < now
                }
                return false
            }
            
            let identifiers = outdatedRequests.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            print("Cleaned up \(identifiers.count) old notifications")
        }
    }
}
