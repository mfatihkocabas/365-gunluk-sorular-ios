import Foundation

class QuestionDataManager: ObservableObject {
    static let shared = QuestionDataManager()
    
    private let questions: [Question]
    
    private init() {
        // 365 günlük sorular - gerçek projede bu JSON dosyasından yüklenecek
        self.questions = QuestionDataManager.loadQuestions()
    }
    
    func getQuestion(for dayOfYear: Int) -> Question? {
        guard dayOfYear >= 1 && dayOfYear <= 365 else { return nil }
        return questions.first { $0.dayOfYear == dayOfYear }
    }
    
    func getQuestion(by id: Int) -> Question? {
        return questions.first { $0.id == id }
    }
    
    func getAllQuestions() -> [Question] {
        return questions
    }
    
    private static func loadQuestions() -> [Question] {
        return loadQuestionsFromFile()
    }
    
    private static func generateSampleQuestions() -> [Question] {
        let sampleQuestions = [
            "Hayatınızda şu anda en önemli olan şey nedir?",
            "Bugün kendinize ne gibi bir iyilik yaptınız?",
            "En son ne zaman birine teşekkür ettiniz?",
            "Hayatınızda en önemli öğretmen kim oldu?",
            "En son ne zaman birine ihtiyacı olmadan yardım ettiniz?",
            "Geçen yıl verdiğiniz en iyi kararın ne olduğunu düşünüyorsunuz?",
            "Hayatınızda önemli bir dönüm noktası neydi?",
            "En çok hangi konuda merak ediyorsunuz?",
            "Son bir haftada sizi en çok mutlu eden şey neydi?",
            "Gelecek için en büyük umudunuz nedir?",
            "Hangi özelliğinizle en çok gurur duyuyorsunuz?",
            "En son ne zaman tamamen kendiniz oldunuz?",
            "Hayatınızı değiştiren bir kitap, film veya kişi var mı?",
            "Bir gün geri dönebilseydiniz hangi günü seçerdiniz?",
            "Şu anda en çok kimin yanında olmak istiyorsunuz?",
            "Hayatınızda 'keşke' dediğiniz bir şey var mı?",
            "En büyük korkularınızdan biri nedir?",
            "Kendinizi en güçlü hissettiğiniz an ne zaman oldu?",
            "Bir yıl sonra kendinizi nerede görmek istiyorsunuz?",
            "Hayatınızda en değerli olan şey nedir?"
        ]
        
        var questions: [Question] = []
        
        for i in 1...365 {
            let questionText = sampleQuestions[(i - 1) % sampleQuestions.count]
            let category = Question.QuestionCategory.allCases.randomElement()
            
            let question = Question(
                id: i,
                text: questionText,
                category: category,
                dayOfYear: i
            )
            questions.append(question)
        }
        
        return questions
    }
}

// MARK: - JSON Loading Support
extension QuestionDataManager {
    static func loadQuestionsFromFile() -> [Question] {
        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let questions = try? JSONDecoder().decode([Question].self, from: data) else {
            print("Questions.json dosyası bulunamadı, örnek sorular kullanılıyor")
            return generateSampleQuestions()
        }
        return questions
    }
}
