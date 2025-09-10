import Foundation

struct Answer: Codable, Identifiable {
    let id: UUID
    let questionId: Int
    let text: String
    let date: Date
    let isFavorite: Bool
    let emoji: String?
    let mood: MoodType?
    
    init(questionId: Int, text: String, isFavorite: Bool = false, emoji: String? = nil, mood: MoodType? = nil, date: Date = Date()) {
        self.id = UUID()
        self.questionId = questionId
        self.text = text
        self.date = date
        self.isFavorite = isFavorite
        self.emoji = emoji
        self.mood = mood
    }
    
    enum MoodType: String, Codable, CaseIterable {
        case veryHappy = "😄"
        case happy = "😊"
        case neutral = "😐"
        case sad = "😔"
        case verySad = "😢"
        case excited = "🤩"
        case grateful = "🙏"
        case thoughtful = "🤔"
        case calm = "😌"
        case energetic = "⚡"
        
        var description: String {
            switch self {
            case .veryHappy: return "Çok Mutlu"
            case .happy: return "Mutlu"
            case .neutral: return "Normal"
            case .sad: return "Üzgün"
            case .verySad: return "Çok Üzgün"
            case .excited: return "Heyecanlı"
            case .grateful: return "Minnettarlık"
            case .thoughtful: return "Düşünceli"
            case .calm: return "Sakin"
            case .energetic: return "Enerjik"
            }
        }
    }
}

extension Answer {
    var yearFromDate: Int {
        Calendar.current.component(.year, from: date)
    }
    
    var dayOfYear: Int {
        Calendar.current.dayOfYear(for: date) ?? 1
    }
}
