import Foundation

struct Question: Codable, Identifiable {
    let id: Int
    let text: String
    let category: QuestionCategory?
    let dayOfYear: Int // 1-365 arası değer
    
    enum QuestionCategory: String, Codable, CaseIterable {
        case self_reflection = "Öz Düşünce"
        case relationships = "İlişkiler"
        case goals = "Hedefler"
        case gratitude = "Minnettarlık"
        case creativity = "Yaratıcılık"
        case lifestyle = "Yaşam Tarzı"
        case emotions = "Duygular"
        case memories = "Anılar"
        case future = "Gelecek"
        case personal_growth = "Kişisel Gelişim"
    }
}

extension Question {
    static func questionForDay(_ dayOfYear: Int) -> Question? {
        return QuestionDataManager.shared.getQuestion(for: dayOfYear)
    }
    
    static func todaysQuestion() -> Question? {
        let dayOfYear = Calendar.current.dayOfYear(for: Date()) ?? 1
        return questionForDay(dayOfYear)
    }
}
