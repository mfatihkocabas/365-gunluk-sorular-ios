import Foundation
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            DispatchQueue.main.async {
                print("Notification permission granted: \(granted)")
            }
        }
    }
    
    func scheduleOneYearReminder(for answer: Answer) {
        guard answer.isFavorite else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Bir Yıl Önceki Düşüncen"
        content.body = "1 yıl önce bu soruya '\(answer.text.prefix(50))...' yazmıştın. Bugün ne düşünüyorsun?"
        content.sound = .default
        content.userInfo = [
            "questionId": answer.questionId,
            "originalDate": answer.date.timeIntervalSince1970
        ]
        
        // Tam 1 yıl sonrası için tarih hesapla
        let oneYearLater = Calendar.current.date(byAdding: .year, value: 1, to: answer.date) ?? Date()
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: oneYearLater)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let identifier = "reminder_\(answer.questionId)_\(answer.date.timeIntervalSince1970)"
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification scheduling error: \(error)")
            } else {
                print("Notification scheduled for question \(answer.questionId)")
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
