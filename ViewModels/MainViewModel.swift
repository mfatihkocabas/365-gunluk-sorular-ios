import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var todayQuestion: Question?
    @Published var todayAnswer: Answer?
    @Published var previousYearAnswers: [Answer] = []
    @Published var answerText: String = ""
    @Published var selectedEmoji: String?
    @Published var selectedMood: Answer.MoodType?
    @Published var isFavorite: Bool = false
    @Published var isLoading: Bool = false
    @Published var showingComparison: Bool = false
    @Published var showingPreviousAnswer: Bool = false
    @Published var showingCalendar: Bool = false
    @Published var showingFavorites: Bool = false
    @Published var answeredDays: Set<Date> = []
    @Published var showingNoPreviousAnswerAlert: Bool = false
    
    private let dataManager = DataManager.shared
    private let questionManager = QuestionDataManager.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        loadTodayQuestion()
        loadTodayAnswer()
        loadPreviousYearAnswers()
        loadAnsweredDays()
    }
    
    // MARK: - Public Methods
    func loadTodayQuestion() {
        let dayOfYear = Calendar.current.dayOfYear(for: Date()) ?? 1
        todayQuestion = questionManager.getQuestion(for: dayOfYear)
    }
    
    func loadTodayAnswer() {
        guard let question = todayQuestion else { return }
        
        if let answer = dataManager.getAnswer(for: question.id, date: Date()) {
            todayAnswer = answer
            answerText = answer.text
            selectedEmoji = answer.emoji
            selectedMood = answer.mood
            isFavorite = answer.isFavorite
        } else {
            // Bugün için cevap yok, temiz başla
            resetAnswer()
        }
    }
    
    func loadPreviousYearAnswers() {
        guard let question = todayQuestion else { return }
        
        let currentYear = Calendar.current.component(.year, from: Date())
        let dayOfYear = Calendar.current.dayOfYear(for: Date()) ?? 1
        
        previousYearAnswers.removeAll()
        
        // Son 5 yılı kontrol et
        for yearsAgo in 1...5 {
            let targetYear = currentYear - yearsAgo
            
            // O yılın aynı gününün tarihini bul
            if let targetDate = Calendar.current.dateFromDayOfYear(dayOfYear, year: targetYear),
               let answer = dataManager.getAnswer(for: question.id, date: targetDate) {
                previousYearAnswers.append(answer)
            }
        }
        
        // En yeni önce olacak şekilde sırala
        previousYearAnswers.sort { $0.date > $1.date }
    }
    
    func saveAnswer() {
        guard let question = todayQuestion else { return }
        guard answerText.isNotEmpty else { return }
        
        // Günde tek kayıt kontrolü - Bugün için zaten cevap var mı?
        if dataManager.getAnswer(for: question.id, date: Date()) != nil {
            // Bugün için zaten cevap verilmiş
            return
        }
        
        isLoading = true
        
        let answer = Answer(
            questionId: question.id,
            text: answerText.trimmed,
            isFavorite: isFavorite,
            emoji: selectedEmoji,
            mood: selectedMood
        )
        
        dataManager.saveAnswer(answer)
        
        // Takvime bugünü kaydet ve disable et
        let today = Date()
        answeredDays.insert(today)
        dataManager.markDayAsAnswered(today)
        
        // Favori ise bildirim ayarla ve favori sayfasına ekle
        if isFavorite {
            notificationManager.scheduleOneYearReminder(for: answer)
            dataManager.addToFavorites(answer)
        } else if let existingAnswer = todayAnswer, existingAnswer.isFavorite {
            // Favori olmaktan çıkarıldıysa bildirimi iptal et ve favorilerden kaldır
            notificationManager.cancelReminder(for: existingAnswer)
            dataManager.removeFromFavorites(existingAnswer)
        }
        
        todayAnswer = answer
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isLoading = false
        }
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
    }
    
    func selectEmoji(_ emoji: String) {
        selectedEmoji = selectedEmoji == emoji ? nil : emoji
    }
    
    func selectMood(_ mood: Answer.MoodType) {
        selectedMood = selectedMood == mood ? nil : mood
    }
    
    func resetAnswer() {
        answerText = ""
        selectedEmoji = nil
        selectedMood = nil
        isFavorite = false
    }
    
    func showComparison() {
        showingComparison = true
    }
    
    func hideComparison() {
        showingComparison = false
    }
    
    // MARK: - Calendar Management
    func loadAnsweredDays() {
        answeredDays = dataManager.getAnsweredDays()
    }
    
    func isDayAnswered(_ date: Date) -> Bool {
        return answeredDays.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    // MARK: - Navigation Functions
    func showTimeCapsule() {
        if hasPreviousAnswers {
            showingPreviousAnswer = true
        } else {
            showingNoPreviousAnswerAlert = true
        }
    }
    
    func showCalendar() {
        showingCalendar = true
    }
    
    func hideCalendar() {
        showingCalendar = false
    }
    
    func showFavorites() {
        showingFavorites = true
    }
    
    func hideFavorites() {
        showingFavorites = false
    }
    
    func hidePreviousAnswer() {
        showingPreviousAnswer = false
    }
    
    func hideNoPreviousAnswerAlert() {
        showingNoPreviousAnswerAlert = false
    }
    
    func removeFromFavorites(_ answer: Answer) {
        dataManager.removeFromFavorites(answer)
        // Reload favorites list
        loadAnsweredDays()
    }
    
    // MARK: - Computed Properties
    var canSave: Bool {
        guard let question = todayQuestion else { return false }
        let alreadyAnsweredToday = dataManager.getAnswer(for: question.id, date: Date()) != nil
        return answerText.isNotEmpty && !isLoading && !alreadyAnsweredToday
    }
    
    var hasAnsweredToday: Bool {
        todayAnswer != nil
    }
    
    var hasPreviousAnswers: Bool {
        !previousYearAnswers.isEmpty
    }
    
    var questionTitle: String {
        todayQuestion?.text ?? "Soru yükleniyor..."
    }
    
    var questionCategory: String {
        todayQuestion?.category?.rawValue ?? ""
    }
    
    var todayDateString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        return formatter.string(from: Date())
    }
    
    var dayOfYear: Int {
        Calendar.current.dayOfYear(for: Date()) ?? 1
    }
}

// MARK: - Sample Data for Preview
extension MainViewModel {
    static func sampleViewModel() -> MainViewModel {
        let viewModel = MainViewModel()
        viewModel.todayQuestion = Question(
            id: 1,
            text: "Hayatınızda şu anda en önemli olan şey nedir?",
            category: .self_reflection,
            dayOfYear: 1
        )
        viewModel.answerText = "Ailemi ve sağlığımı. Bu zorlu dönemde onların desteği çok değerli."
        return viewModel
    }
}
