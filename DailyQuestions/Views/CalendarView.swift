import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Yıl ve Ay Seçici
                DatePickerHeader(viewModel: viewModel)
                
                // Takvim Grid
                CalendarGrid(viewModel: viewModel)
                
                // Seçilen Günün Detayları
                if let selectedDay = viewModel.selectedDay {
                    SelectedDayView(viewModel: viewModel, selectedDay: selectedDay)
                }
                
                Spacer()
            }
            .navigationTitle("Takvim Görünümü")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Date Picker Header
struct DatePickerHeader: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { viewModel.previousMonth() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.accent)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(viewModel.monthYearString)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primaryText)
                    
                    Text("\(viewModel.answeredDaysInMonth) gün cevaplandı")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                Button(action: { viewModel.nextMonth() }) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .foregroundColor(.accent)
                }
            }
            .padding(.horizontal)
            
            // Yıl Seçici
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableYears, id: \.self) { year in
                        Button(action: {
                            viewModel.selectYear(year)
                        }) {
                            Text("\(year)")
                                .font(.subheadline)
                                .fontWeight(viewModel.selectedYear == year ? .bold : .medium)
                                .foregroundColor(viewModel.selectedYear == year ? .white : .accent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(viewModel.selectedYear == year ? Color.accent : Color.clear)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color.accent, lineWidth: viewModel.selectedYear == year ? 0 : 1)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
    }
}

// MARK: - Calendar Grid
struct CalendarGrid: View {
    @ObservedObject var viewModel: CalendarViewModel
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekdays = ["Pt", "Sa", "Ça", "Pe", "Cu", "Ct", "Pz"]
    
    var body: some View {
        VStack(spacing: 8) {
            // Hafta günleri başlığı
            HStack {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondaryText)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Takvim günleri
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(viewModel.calendarDays, id: \.self) { day in
                    CalendarDayView(
                        day: day,
                        isSelected: viewModel.selectedDay == day,
                        hasAnswer: viewModel.hasAnswer(for: day),
                        isFavorite: viewModel.isFavorite(for: day),
                        isToday: viewModel.isToday(day),
                        isCurrentMonth: viewModel.isCurrentMonth(day)
                    ) {
                        viewModel.selectDay(day)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

// MARK: - Calendar Day View
struct CalendarDayView: View {
    let day: Date
    let isSelected: Bool
    let hasAnswer: Bool
    let isFavorite: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let onTap: () -> Void
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: day)
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)
                
                if hasAnswer {
                    Circle()
                        .stroke(borderColor, lineWidth: 2)
                        .frame(width: 40, height: 40)
                }
                
                Text(dayNumber)
                    .font(.subheadline)
                    .fontWeight(isToday ? .bold : .medium)
                    .foregroundColor(textColor)
                
                if isFavorite {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Circle()
                                .fill(Color.favoriteRed)
                                .frame(width: 6, height: 6)
                        }
                    }
                    .frame(width: 40, height: 40)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isCurrentMonth ? 1.0 : 0.3)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .accent
        } else if isToday {
            return .accent.opacity(0.2)
        } else if hasAnswer {
            return .successGreen.opacity(0.1)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        if isFavorite {
            return .favoriteRed
        } else if hasAnswer {
            return .successGreen
        } else {
            return .clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else if isToday {
            return .accent
        } else {
            return .primaryText
        }
    }
}

// MARK: - Selected Day View
struct SelectedDayView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let selectedDay: Date
    
    var body: some View {
        VStack(spacing: 16) {
            if let answer = viewModel.getAnswer(for: selectedDay) {
                AnswerDetailCard(answer: answer, question: viewModel.getQuestion(for: selectedDay))
            } else {
                NoAnswerCard(date: selectedDay, question: viewModel.getQuestion(for: selectedDay))
            }
        }
        .padding(.horizontal)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Answer Detail Card
struct AnswerDetailCard: View {
    let answer: Answer
    let question: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formattedDate(answer.date))
                    .font(.headline)
                    .foregroundColor(.accent)
                
                Spacer()
                
                HStack(spacing: 8) {
                    if let emoji = answer.emoji {
                        Text(emoji)
                            .font(.title3)
                    }
                    
                    if answer.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.favoriteRed)
                    }
                }
            }
            
            Text(question)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .lineLimit(nil)
            
            Text(answer.text)
                .font(.body)
                .foregroundColor(.primaryText)
                .lineLimit(nil)
            
            if let mood = answer.mood {
                HStack {
                    Text(mood.rawValue)
                    Text(mood.description)
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                    Spacer()
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - No Answer Card
struct NoAnswerCard: View {
    let date: Date
    let question: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(formattedDate(date))
                    .font(.headline)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.secondaryText)
                    .font(.title2)
            }
            
            Text(question)
                .font(.subheadline)
                .foregroundColor(.secondaryText)
                .lineLimit(nil)
            
            Text("Bu gün için henüz cevap yazılmamış.")
                .font(.body)
                .foregroundColor(.secondaryText)
                .italic()
        }
        .padding()
        .cardStyle()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy, EEEE"
        return formatter.string(from: date)
    }
}

// MARK: - Calendar ViewModel
class CalendarViewModel: ObservableObject {
    @Published var selectedYear: Int
    @Published var selectedMonth: Int
    @Published var selectedDay: Date?
    @Published var calendarDays: [Date] = []
    
    private let dataManager = DataManager.shared
    private let questionManager = QuestionDataManager.shared
    private var answers: [Answer] = []
    
    let availableYears: [Int]
    
    init() {
        let currentYear = Calendar.current.component(.year, from: Date())
        self.selectedYear = currentYear
        self.selectedMonth = Calendar.current.component(.month, from: Date())
        self.availableYears = Array((currentYear - 5)...currentYear).reversed()
        
        loadAnswers()
        generateCalendarDays()
    }
    
    func loadAnswers() {
        answers = dataManager.getAnswersForYear(selectedYear)
    }
    
    func generateCalendarDays() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = selectedYear
        components.month = selectedMonth
        components.day = 1
        
        guard let firstOfMonth = calendar.date(from: components) else { return }
        
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let numberOfDays = range.count
        
        // Ayın ilk gününün haftanın hangi günü olduğunu bul
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let firstWeekdayAdjusted = (firstWeekday + 5) % 7 // Pazartesi = 0 olacak şekilde ayarla
        
        calendarDays.removeAll()
        
        // Önceki ayın günlerini ekle
        for i in (1...firstWeekdayAdjusted).reversed() {
            if let date = calendar.date(byAdding: .day, value: -i, to: firstOfMonth) {
                calendarDays.append(date)
            }
        }
        
        // Bu ayın günlerini ekle
        for day in 1...numberOfDays {
            components.day = day
            if let date = calendar.date(from: components) {
                calendarDays.append(date)
            }
        }
        
        // Sonraki ayın günlerini ekle (toplam 42 gün olana kadar)
        let remainingDays = 42 - calendarDays.count
        for i in 1...remainingDays {
            components.day = numberOfDays + i
            if let date = calendar.date(from: components) {
                calendarDays.append(date)
            }
        }
    }
    
    func selectYear(_ year: Int) {
        selectedYear = year
        loadAnswers()
        generateCalendarDays()
        selectedDay = nil
    }
    
    func previousMonth() {
        if selectedMonth == 1 {
            selectedMonth = 12
            selectedYear -= 1
        } else {
            selectedMonth -= 1
        }
        loadAnswers()
        generateCalendarDays()
        selectedDay = nil
    }
    
    func nextMonth() {
        if selectedMonth == 12 {
            selectedMonth = 1
            selectedYear += 1
        } else {
            selectedMonth += 1
        }
        loadAnswers()
        generateCalendarDays()
        selectedDay = nil
    }
    
    func selectDay(_ day: Date) {
        selectedDay = day
    }
    
    func hasAnswer(for date: Date) -> Bool {
        let dayOfYear = Calendar.current.dayOfYear(for: date) ?? 0
        let year = Calendar.current.component(.year, from: date)
        
        return answers.contains { answer in
            let answerDayOfYear = Calendar.current.dayOfYear(for: answer.date) ?? 0
            let answerYear = Calendar.current.component(.year, from: answer.date)
            return answerDayOfYear == dayOfYear && answerYear == year
        }
    }
    
    func isFavorite(for date: Date) -> Bool {
        let dayOfYear = Calendar.current.dayOfYear(for: date) ?? 0
        let year = Calendar.current.component(.year, from: date)
        
        return answers.contains { answer in
            let answerDayOfYear = Calendar.current.dayOfYear(for: answer.date) ?? 0
            let answerYear = Calendar.current.component(.year, from: answer.date)
            return answerDayOfYear == dayOfYear && answerYear == year && answer.isFavorite
        }
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func isCurrentMonth(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let year = calendar.component(.year, from: date)
        return month == selectedMonth && year == selectedYear
    }
    
    func getAnswer(for date: Date) -> Answer? {
        let dayOfYear = Calendar.current.dayOfYear(for: date) ?? 0
        let year = Calendar.current.component(.year, from: date)
        
        return answers.first { answer in
            let answerDayOfYear = Calendar.current.dayOfYear(for: answer.date) ?? 0
            let answerYear = Calendar.current.component(.year, from: answer.date)
            return answerDayOfYear == dayOfYear && answerYear == year
        }
    }
    
    func getQuestion(for date: Date) -> String {
        let dayOfYear = Calendar.current.dayOfYear(for: date) ?? 1
        if let question = questionManager.getQuestion(for: dayOfYear) {
            return question.text
        }
        return "Soru bulunamadı"
    }
    
    var monthYearString: String {
        let monthNames = [
            1: "Ocak", 2: "Şubat", 3: "Mart", 4: "Nisan", 5: "Mayıs", 6: "Haziran",
            7: "Temmuz", 8: "Ağustos", 9: "Eylül", 10: "Ekim", 11: "Kasım", 12: "Aralık"
        ]
        return "\(monthNames[selectedMonth] ?? "") \(selectedYear)"
    }
    
    var answeredDaysInMonth: Int {
        let calendar = Calendar.current
        return answers.filter { answer in
            let month = calendar.component(.month, from: answer.date)
            let year = calendar.component(.year, from: answer.date)
            return month == selectedMonth && year == selectedYear
        }.count
    }
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
}
