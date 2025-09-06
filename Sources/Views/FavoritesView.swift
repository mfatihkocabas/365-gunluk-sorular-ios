import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.favoriteAnswers.isEmpty {
                    EmptyFavoritesView()
                } else {
                    FavoritesList(viewModel: viewModel)
                }
            }
            .navigationTitle("Favori Sorularım")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Bildirimleri Göster") {
                        viewModel.showNotifications()
                    }
                    .font(.caption)
                }
            }
            .onAppear {
                viewModel.loadFavorites()
            }
        }
    }
}

// MARK: - Empty Favorites View
struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart")
                .font(.system(size: 80))
                .foregroundColor(.secondaryText)
            
            Text("Henüz Favori Soru Yok")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
            
            Text("Sorulari favorilere eklediğinizde burada görünür ve 1 yıl sonra size hatırlatılır.")
                .font(.body)
                .foregroundColor(.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Button(action: {
                // Tab değiştirme NotificationCenter ile yapılacak
                NotificationCenter.default.post(name: NSNotification.Name("SwitchToTodayTab"), object: nil)
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("İlk Favori Sorunu Ekle")
                }
                .font(.headline)
                .primaryButtonStyle()
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
    }
}

// MARK: - Favorites List
struct FavoritesList: View {
    @ObservedObject var viewModel: FavoritesViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // İstatistikler
            FavoritesStatsView(viewModel: viewModel)
            
            // Favoriler Listesi
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.favoriteAnswers) { answer in
                        FavoriteAnswerCard(answer: answer, onRemove: {
                            viewModel.removeFavorite(answer)
                        })
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Favorites Stats
struct FavoritesStatsView: View {
    @ObservedObject var viewModel: FavoritesViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            StatItem(
                title: "Toplam Favori",
                value: "\(viewModel.favoriteAnswers.count)",
                icon: "heart.fill",
                color: .favoriteRed
            )
            
            StatItem(
                title: "Bu Yıl",
                value: "\(viewModel.thisYearFavorites)",
                icon: "calendar",
                color: .blue
            )
            
            StatItem(
                title: "Aktif Hatırlatma",
                value: "\(viewModel.activeReminders)",
                icon: "bell.fill",
                color: .orange
            )
        }
        .padding(.horizontal)
    }
}

// MARK: - Stat Item
struct StatItem: View {
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
                .font(.title3)
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

// MARK: - Favorite Answer Card
struct FavoriteAnswerCard: View {
    let answer: Answer
    let onRemove: () -> Void
    @State private var isExpanded = false
    @State private var showingRemoveAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(questionForAnswer(answer))
                        .font(.headline)
                        .foregroundColor(.primaryText)
                        .lineLimit(isExpanded ? nil : 2)
                    
                    HStack {
                        Text(formattedDate(answer.date))
                            .font(.caption)
                            .foregroundColor(.secondaryText)
                        
                        Text("•")
                            .foregroundColor(.secondaryText)
                            .font(.caption)
                        
                        Text("1 yıl sonra: \(formattedReminderDate(answer.date))")
                            .font(.caption)
                            .foregroundColor(.accent)
                    }
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    if let emoji = answer.emoji {
                        Text(emoji)
                            .font(.title3)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.accent)
                    }
                    
                    Button(action: {
                        showingRemoveAlert = true
                    }) {
                        Image(systemName: "heart.slash")
                            .foregroundColor(.favoriteRed)
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
                
                // Hatırlatma Durumu
                ReminderStatusView(answer: answer)
            }
        }
        .padding()
        .cardStyle()
        .alert("Favorilerden Çıkar", isPresented: $showingRemoveAlert) {
            Button("İptal", role: .cancel) { }
            Button("Çıkar", role: .destructive) {
                onRemove()
            }
        } message: {
            Text("Bu soruyu favorilerden çıkarmak istediğinizden emin misiniz? Hatırlatma bildirimi de iptal edilecek.")
        }
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
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: date)
    }
    
    private func formattedReminderDate(_ date: Date) -> String {
        let oneYearLater = Calendar.current.date(byAdding: .year, value: 1, to: date) ?? date
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMM yyyy"
        return formatter.string(from: oneYearLater)
    }
}

// MARK: - Reminder Status View
struct ReminderStatusView: View {
    let answer: Answer
    
    var body: some View {
        let reminderDate = Calendar.current.date(byAdding: .year, value: 1, to: answer.date) ?? answer.date
        let now = Date()
        let isOverdue = reminderDate < now
        let daysDifference = Calendar.current.dateComponents([.day], from: now, to: reminderDate).day ?? 0
        
        HStack {
            Image(systemName: isOverdue ? "bell.slash" : "bell")
                .foregroundColor(isOverdue ? .secondaryText : .orange)
            
            if isOverdue {
                Text("Hatırlatma geçti")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            } else if daysDifference <= 7 {
                Text("Hatırlatma çok yakında!")
                    .font(.caption)
                    .foregroundColor(.orange)
            } else {
                Text("\(daysDifference) gün sonra hatırlatılacak")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
            }
            
            Spacer()
        }
        .padding(.top, 8)
    }
}

// MARK: - Favorites ViewModel
class FavoritesViewModel: ObservableObject {
    @Published var favoriteAnswers: [Answer] = []
    
    private let dataManager = DataManager.shared
    private let notificationManager = NotificationManager.shared
    
    func loadFavorites() {
        favoriteAnswers = dataManager.getFavoriteAnswers()
    }
    
    func removeFavorite(_ answer: Answer) {
        // Favori durumunu kaldır
        let updatedAnswer = Answer(
            questionId: answer.questionId,
            text: answer.text,
            isFavorite: false,
            emoji: answer.emoji,
            mood: answer.mood
        )
        
        dataManager.saveAnswer(updatedAnswer)
        notificationManager.cancelReminder(for: answer)
        
        // Liste'yi güncelle
        favoriteAnswers.removeAll { $0.id == answer.id }
    }
    
    func showNotifications() {
        notificationManager.listPendingNotifications()
    }
    
    var thisYearFavorites: Int {
        let currentYear = Calendar.current.component(.year, from: Date())
        return favoriteAnswers.filter { answer in
            Calendar.current.component(.year, from: answer.date) == currentYear
        }.count
    }
    
    var activeReminders: Int {
        let now = Date()
        return favoriteAnswers.filter { answer in
            let reminderDate = Calendar.current.date(byAdding: .year, value: 1, to: answer.date) ?? answer.date
            return reminderDate > now
        }.count
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
