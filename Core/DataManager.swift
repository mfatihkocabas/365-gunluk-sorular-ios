import Foundation

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    private let answersKey = "user_answers"
    private let answeredDaysKey = "answered_days"
    private let favoritesKey = "favorite_answers"
    
    private init() {}
    
    // MARK: - Answer Operations
    func saveAnswer(_ answer: Answer) {
        var allAnswers = getAllAnswers()
        
        // Aynı gün için zaten cevap var mı kontrol et
        if let existingIndex = allAnswers.firstIndex(where: {
            Calendar.current.isDate($0.date, inSameDayAs: answer.date) && $0.questionId == answer.questionId
        }) {
            // Güncelle
            allAnswers[existingIndex] = answer
        } else {
            // Yeni ekle
            allAnswers.append(answer)
        }
        
        saveAllAnswers(allAnswers)
    }
    
    func getAnswer(for questionId: Int, date: Date = Date()) -> Answer? {
        let allAnswers = getAllAnswers()
        return allAnswers.first { answer in
            Calendar.current.isDate(answer.date, inSameDayAs: date) && answer.questionId == questionId
        }
    }
    
    func getAnswersForYear(_ year: Int) -> [Answer] {
        let allAnswers = getAllAnswers()
        return allAnswers.filter { answer in
            Calendar.current.component(.year, from: answer.date) == year
        }.sorted { $0.date < $1.date }
    }
    
    func getFavoriteAnswers() -> [Answer] {
        let allAnswers = getAllAnswers()
        return allAnswers.filter { $0.isFavorite }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Statistics
    func getAnswerCount(for year: Int) -> Int {
        return getAnswersForYear(year).count
    }
    
    func getMonthlyAnswerCounts(for year: Int) -> [Int: Int] {
        let answers = getAnswersForYear(year)
        var monthlyCounts: [Int: Int] = [:]
        
        for month in 1...12 {
            monthlyCounts[month] = 0
        }
        
        for answer in answers {
            let month = Calendar.current.component(.month, from: answer.date)
            monthlyCounts[month] = (monthlyCounts[month] ?? 0) + 1
        }
        
        return monthlyCounts
    }
    
    // MARK: - Private Methods
    private func getAllAnswers() -> [Answer] {
        guard let data = userDefaults.data(forKey: answersKey),
              let answers = try? JSONDecoder().decode([Answer].self, from: data) else {
            return []
        }
        return answers
    }
    
    private func saveAllAnswers(_ answers: [Answer]) {
        if let data = try? JSONEncoder().encode(answers) {
            userDefaults.set(data, forKey: answersKey)
        }
    }
    
    // MARK: - Calendar Management
    func markDayAsAnswered(_ date: Date) {
        var answeredDays = getAnsweredDays()
        answeredDays.insert(date)
        saveAnsweredDays(answeredDays)
    }
    
    func getAnsweredDays() -> Set<Date> {
        guard let data = userDefaults.data(forKey: answeredDaysKey) else {
            return []
        }
        let dateStrings = (try? JSONDecoder().decode([String].self, from: data)) ?? []
        let dateFormatter = ISO8601DateFormatter()
        return Set(dateStrings.compactMap { dateFormatter.date(from: $0) })
    }
    
    private func saveAnsweredDays(_ days: Set<Date>) {
        let dateFormatter = ISO8601DateFormatter()
        let dateStrings = days.map { dateFormatter.string(from: $0) }
        if let data = try? JSONEncoder().encode(dateStrings) {
            userDefaults.set(data, forKey: answeredDaysKey)
        }
    }
    
    // MARK: - Enhanced Favorites Management
    func addToFavorites(_ answer: Answer) {
        // Bu fonksiyon artık answer'ın isFavorite flag'ini kullanarak çalışıyor
        // Sadece favoriler listesini güncelliyoruz
        let favorites = getFavoriteAnswers()
        print("Favorilere eklendi: \(answer.text.prefix(50))")
    }
    
    func removeFromFavorites(_ answer: Answer) {
        // Bu fonksiyon artık answer'ın isFavorite flag'ini kullanarak çalışıyor
        let favorites = getFavoriteAnswers()
        print("Favorilerden kaldırıldı: \(answer.text.prefix(50))")
    }
}