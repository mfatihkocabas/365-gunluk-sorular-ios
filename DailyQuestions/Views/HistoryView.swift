import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Yıl Seçici
                YearPickerView(selectedYear: $viewModel.selectedYear)
                
                // İstatistikler
                StatisticsSection(viewModel: viewModel)
                
                // Cevap Listesi
                AnswersList(viewModel: viewModel)
            }
            .navigationTitle("Geçmiş Cevaplarım")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.loadAnswers()
            }
        }
    }
}

// MARK: - Year Picker
struct YearPickerView: View {
    @Binding var selectedYear: Int
    
    private var availableYears: [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (currentYear - 5...currentYear).reversed()
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(availableYears, id: \.self) { year in
                    Button(action: {
                        selectedYear = year
                    }) {
                        Text("\(year)")
                            .font(.headline)
                            .fontWeight(selectedYear == year ? .bold : .medium)
                            .foregroundColor(selectedYear == year ? .white : .accent)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(selectedYear == year ? Color.accent : Color.clear)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.accent, lineWidth: selectedYear == year ? 0 : 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Statistics Section
struct StatisticsSection: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                StatCard(
                    title: "Toplam Cevap",
                    value: "\(viewModel.totalAnswers)",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Favori Soru",
                    value: "\(viewModel.favoriteAnswers)",
                    icon: "heart.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Tamamlanan",
                    value: "%\(viewModel.completionPercentage)",
                    icon: "chart.bar.fill",
                    color: .green
                )
            }
            
            // Aylık Dağılım Grafiği
            MonthlyChartView(monthlyData: viewModel.monthlyAnswerCounts)
        }
        .padding(.horizontal)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .cardStyle()
    }
}

// MARK: - Monthly Chart
struct MonthlyChartView: View {
    let monthlyData: [Int: Int]
    
    private let monthNames = [
        1: "Oca", 2: "Şub", 3: "Mar", 4: "Nis", 5: "May", 6: "Haz",
        7: "Tem", 8: "Ağu", 9: "Eyl", 10: "Eki", 11: "Kas", 12: "Ara"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Aylık Dağılım")
                .font(.headline)
                .foregroundColor(.primaryText)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(1...12, id: \.self) { month in
                    VStack(spacing: 4) {
                        let count = monthlyData[month] ?? 0
                        let maxCount = monthlyData.values.max() ?? 1
                        let height = CGFloat(count) / CGFloat(maxCount) * 80
                        
                        Rectangle()
                            .fill(Color.accent)
                            .frame(width: 20, height: max(height, 2))
                            .cornerRadius(2)
                        
                        Text(monthNames[month] ?? "")
                            .font(.caption2)
                            .foregroundColor(.secondaryText)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Answers List
struct AnswersList: View {
    @ObservedObject var viewModel: HistoryViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.answers) { answer in
                    HistoryAnswerCard(answer: answer)
                }
                
                if viewModel.answers.isEmpty {
                    EmptyStateView()
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - History Answer Card
struct HistoryAnswerCard: View {
    let answer: Answer
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(questionForAnswer(answer))
                        .font(.headline)
                        .foregroundColor(.primaryText)
                        .lineLimit(2)
                    
                    Text(formattedDate(answer.date))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    if let emoji = answer.emoji {
                        Text(emoji)
                            .font(.title3)
                    }
                    
                    if answer.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.favoriteRed)
                            .font(.caption)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.accent)
                    }
                }
            }
            
            if isExpanded {
                Text(answer.text)
                    .font(.body)
                    .foregroundColor(.primaryText)
                    .lineLimit(nil)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                
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
        }
        .padding()
        .cardStyle()
    }
    
    private func questionForAnswer(_ answer: Answer) -> String {
        if let question = QuestionDataManager.shared.getQuestion(for: answer.questionId) {
            return question.text
        }
        return "Soru bulunamadı"
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 60))
                .foregroundColor(.secondaryText)
            
            Text("Henüz Cevap Yok")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            Text("Bu yıl için henüz hiç soru cevaplamadınız. Ana sayfaya gidip bugünün sorusunu cevaplayabilirsiniz.")
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - History ViewModel
class HistoryViewModel: ObservableObject {
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var answers: [Answer] = []
    @Published var monthlyAnswerCounts: [Int: Int] = [:]
    
    private let dataManager = DataManager.shared
    
    init() {
        loadAnswers()
    }
    
    func loadAnswers() {
        answers = dataManager.getAnswersForYear(selectedYear)
        monthlyAnswerCounts = dataManager.getMonthlyAnswerCounts(for: selectedYear)
    }
    
    var totalAnswers: Int {
        answers.count
    }
    
    var favoriteAnswers: Int {
        answers.filter { $0.isFavorite }.count
    }
    
    var completionPercentage: Int {
        let daysPassed = Calendar.current.dayOfYear(for: Date()) ?? 1
        let currentYear = Calendar.current.component(.year, from: Date())
        
        if selectedYear == currentYear {
            return daysPassed > 0 ? Int((Double(totalAnswers) / Double(daysPassed)) * 100) : 0
        } else {
            return Int((Double(totalAnswers) / 365.0) * 100)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView()
    }
}
