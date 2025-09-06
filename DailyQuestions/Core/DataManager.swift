import Foundation
import CoreData

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save error: \(error)")
            }
        }
    }
    
    // MARK: - Answer Operations
    func saveAnswer(_ answer: Answer) {
        // Aynı gün için zaten cevap var mı kontrol et
        if let existingResponse = getUserResponse(for: answer.questionId, date: answer.date) {
            existingResponse.text = answer.text
            existingResponse.isFavorite = answer.isFavorite
            existingResponse.emoji = answer.emoji
            existingResponse.mood = answer.mood?.rawValue
            existingResponse.updatedAt = Date()
        } else {
            let userResponse = UserResponseEntity(context: context)
            userResponse.id = answer.id
            userResponse.questionId = Int32(answer.questionId)
            userResponse.text = answer.text
            userResponse.date = answer.date
            userResponse.isFavorite = answer.isFavorite
            userResponse.emoji = answer.emoji
            userResponse.mood = answer.mood?.rawValue
            userResponse.createdAt = Date()
            userResponse.updatedAt = Date()
        }
        
        save()
    }
    
    func getAnswer(for questionId: Int, date: Date = Date()) -> Answer? {
        guard let userResponse = getUserResponse(for: questionId, date: date) else {
            return nil
        }
        
        let mood = userResponse.mood != nil ? Answer.MoodType(rawValue: userResponse.mood!) : nil
        
        return Answer(
            questionId: Int(userResponse.questionId),
            text: userResponse.text ?? "",
            isFavorite: userResponse.isFavorite,
            emoji: userResponse.emoji,
            mood: mood
        )
    }
    
    func getAnswersForYear(_ year: Int) -> [Answer] {
        let request: NSFetchRequest<UserResponseEntity> = UserResponseEntity.fetchRequest()
        
        let startDate = Date.startOfYear(year)
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? Date()
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserResponseEntity.date, ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                let mood = entity.mood != nil ? Answer.MoodType(rawValue: entity.mood!) : nil
                return Answer(
                    questionId: Int(entity.questionId),
                    text: entity.text ?? "",
                    isFavorite: entity.isFavorite,
                    emoji: entity.emoji,
                    mood: mood
                )
            }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    func getFavoriteAnswers() -> [Answer] {
        let request: NSFetchRequest<UserResponseEntity> = UserResponseEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == true")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserResponseEntity.date, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { entity in
                let mood = entity.mood != nil ? Answer.MoodType(rawValue: entity.mood!) : nil
                return Answer(
                    questionId: Int(entity.questionId),
                    text: entity.text ?? "",
                    isFavorite: entity.isFavorite,
                    emoji: entity.emoji,
                    mood: mood
                )
            }
        } catch {
            print("Fetch error: \(error)")
            return []
        }
    }
    
    private func getUserResponse(for questionId: Int, date: Date) -> UserResponseEntity? {
        let request: NSFetchRequest<UserResponseEntity> = UserResponseEntity.fetchRequest()
        
        let dayOfYear = Calendar.current.dayOfYear(for: date) ?? 1
        let year = Calendar.current.component(.year, from: date)
        
        request.predicate = NSPredicate(format: "questionId == %d", questionId)
        
        do {
            let entities = try context.fetch(request)
            return entities.first { entity in
                let entityDayOfYear = Calendar.current.dayOfYear(for: entity.date ?? Date()) ?? 0
                let entityYear = Calendar.current.component(.year, from: entity.date ?? Date())
                return entityDayOfYear == dayOfYear && entityYear == year
            }
        } catch {
            print("Fetch error: \(error)")
            return nil
        }
    }
    
    // MARK: - Statistics
    func getAnswerCount(for year: Int) -> Int {
        let request: NSFetchRequest<UserResponseEntity> = UserResponseEntity.fetchRequest()
        
        let startDate = Date.startOfYear(year)
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: startDate) ?? Date()
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate as NSDate)
        
        do {
            return try context.count(for: request)
        } catch {
            print("Count error: \(error)")
            return 0
        }
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
}

// MARK: - UserResponseEntity
@objc(UserResponseEntity)
class UserResponseEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var questionId: Int32
    @NSManaged var text: String?
    @NSManaged var date: Date?
    @NSManaged var isFavorite: Bool
    @NSManaged var emoji: String?
    @NSManaged var mood: String?
    @NSManaged var createdAt: Date?
    @NSManaged var updatedAt: Date?
}

extension UserResponseEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserResponseEntity> {
        return NSFetchRequest<UserResponseEntity>(entityName: "UserResponseEntity")
    }
}
