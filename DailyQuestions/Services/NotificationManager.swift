import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
        func requestPermission() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error {
                    // Silent error handling
                }
            }
        }
    
    func scheduleOneYearReminder(for answer: Answer) {
        guard answer.isFavorite else { 
            return 
        }
        
        // Bildirim izni kontrol et ve iste
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    self.requestPermission { granted in
                        if granted {
                            self.scheduleNotification(for: answer)
                        }
                    }
                } else if settings.authorizationStatus == .authorized {
                    self.scheduleNotification(for: answer)
                }
            }
        }
    }
    
        private func requestPermission(completion: @escaping (Bool) -> Void) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        }
    
    private func scheduleNotification(for answer: Answer) {
        let content = UNMutableNotificationContent()
        content.title = "Bir Yıl Önceki Düşüncen"
        content.body = "1 yıl önce bu soruya '\(answer.text.prefix(50))...' yazmıştın. Bugün ne düşünüyorsun?"
        content.sound = .default
        content.userInfo = [
            "questionId": answer.questionId,
            "originalDate": answer.date.timeIntervalSince1970
        ]
        
        // Gerçek 1 yıl sonra bildirim
        let oneYearLater = Calendar.current.date(byAdding: .year, value: 1, to: answer.date) ?? Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneYearLater)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "reminder_\(answer.questionId)_\(answer.date.timeIntervalSince1970)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
            UNUserNotificationCenter.current().add(request) { error in
                // Silent error handling
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
    
        // Tüm bekleyen bildirimleri listele
        func listPendingNotifications() {
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                // Silent handling
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
        }
    }
}
