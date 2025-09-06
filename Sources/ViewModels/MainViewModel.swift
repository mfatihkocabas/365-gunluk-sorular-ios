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
    
    private let dataManager = DataManager.shared
    private let questionManager = QuestionDataManager.shared
    private let notificationManager = NotificationManager.shared
    
    init() {
        loadTodayQuestion()
        loadTodayAnswer()
        loadPreviousYearAnswers()
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
        
        isLoading = true
        
        let answer = Answer(
            questionId: question.id,
            text: answerText.trimmed,
            isFavorite: isFavorite,
            emoji: selectedEmoji,
            mood: selectedMood
        )
        
        dataManager.saveAnswer(answer)
        
        // Favori ise bildirim ayarla
        if isFavorite {
            notificationManager.scheduleOneYearReminder(for: answer)
        } else if let existingAnswer = todayAnswer, existingAnswer.isFavorite {
            // Favori olmaktan çıkarıldıysa bildirimi iptal et
            notificationManager.cancelReminder(for: existingAnswer)
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
    
    // MARK: - Computed Properties
    var canSave: Bool {
        answerText.isNotEmpty && !isLoading
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
