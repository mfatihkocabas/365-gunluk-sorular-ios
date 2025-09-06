import SwiftUI

struct TodayView: View {
    @ObservedObject var viewModel: MainViewModel
    @State private var showingPreviousAnswers = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tarih ve Gün Bilgisi
                    HeaderSection(viewModel: viewModel)
                    
                    // Soru Kartı
                    QuestionCard(viewModel: viewModel)
                    
                    // Cevap Yazma Alanı
                    AnswerSection(viewModel: viewModel)
                    
                    // Duygu ve Emoji Seçimi
                    EmotionSection(viewModel: viewModel)
                    
                    // Favorilere Ekle
                    FavoriteSection(viewModel: viewModel)
                    
                    // Geçmiş Cevaplar Butonu
                    if viewModel.hasPreviousAnswers {
                        PreviousAnswersButton(showingPreviousAnswers: $showingPreviousAnswers)
                    }
                    
                    // Kaydet Butonu
                    SaveButton(viewModel: viewModel)
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Günün Sorusu")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPreviousAnswers) {
                PreviousAnswersSheet(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Header Section
struct HeaderSection: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text(viewModel.todayDateString)
                .font(.headline)
                .foregroundColor(.secondaryText)
            
            Text("Gün \(viewModel.dayOfYear)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primaryText)
            
            if !viewModel.questionCategory.isEmpty {
                Text(viewModel.questionCategory)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.accent.opacity(0.1))
                    .foregroundColor(.accent)
                    .cornerRadius(12)
            }
        }
        .padding(.top)
    }
}

// MARK: - Question Card
struct QuestionCard: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.accent)
                    .font(.title2)
                
                Text("Bugünün Sorusu")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
            }
            
            Text(viewModel.questionTitle)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.primaryText)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Answer Section
struct AnswerSection: View {
    @ObservedObject var viewModel: MainViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "pencil.circle.fill")
                    .foregroundColor(.accent)
                    .font(.title2)
                
                Text(viewModel.hasAnsweredToday ? "Cevabını Düzenle" : "Cevabını Yaz")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
                
                if viewModel.hasAnsweredToday {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.successGreen)
                        .font(.title2)
                }
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondaryBackground)
                    .frame(minHeight: 120)
                
                if viewModel.answerText.isEmpty {
                    Text("Düşüncelerini buraya yaz...")
                        .foregroundColor(.secondaryText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                
                TextEditor(text: $viewModel.answerText)
                    .focused($isTextFieldFocused)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.clear)
                    .font(.body)
            }
            
            HStack {
                Text("\(viewModel.answerText.count) karakter")
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                
                Spacer()
                
                if isTextFieldFocused {
                    Button("Tamam") {
                        isTextFieldFocused = false
                    }
                    .font(.caption)
                    .foregroundColor(.accent)
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Emotion Section
struct EmotionSection: View {
    @ObservedObject var viewModel: MainViewModel
    
    let emojis = ["😄", "😊", "😐", "😔", "😢", "🤩", "🙏", "🤔", "😌", "⚡"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "face.smiling")
                    .foregroundColor(.accent)
                    .font(.title2)
                
                Text("Duygu Durumun")
                    .font(.headline)
                    .foregroundColor(.primaryText)
                
                Spacer()
            }
            
            // Emoji Seçimi
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(emojis, id: \.self) { emoji in
                        Button(action: {
                            viewModel.selectEmoji(emoji)
                        }) {
                            Text(emoji)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(viewModel.selectedEmoji == emoji ? Color.accent.opacity(0.2) : Color.clear)
                                )
                                .overlay(
                                    Circle()
                                        .stroke(viewModel.selectedEmoji == emoji ? Color.accent : Color.clear, lineWidth: 2)
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Duygu Tipi Seçimi
            VStack(alignment: .leading, spacing: 8) {
                Text("Duygu Tipi:")
                    .font(.subheadline)
                    .foregroundColor(.secondaryText)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                    ForEach(Answer.MoodType.allCases, id: \.self) { mood in
                        Button(action: {
                            viewModel.selectMood(mood)
                        }) {
                            HStack {
                                Text(mood.rawValue)
                                Text(mood.description)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(viewModel.selectedMood == mood ? Color.accent.opacity(0.2) : Color.secondaryBackground)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(viewModel.selectedMood == mood ? Color.accent : Color.clear, lineWidth: 1)
                            )
                        }
                        .foregroundColor(viewModel.selectedMood == mood ? .accent : .primaryText)
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

// MARK: - Favorite Section
struct FavoriteSection: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        Button(action: {
            viewModel.toggleFavorite()
        }) {
            HStack {
                Image(systemName: viewModel.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(viewModel.isFavorite ? .favoriteRed : .secondaryText)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Favorilere Ekle")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                    
                    Text("1 yıl sonra bu soruyu hatırlatacağım")
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
                
                Spacer()
                
                if viewModel.isFavorite {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.favoriteRed)
                        .font(.title2)
                }
            }
            .padding()
            .cardStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previous Answers Button
struct PreviousAnswersButton: View {
    @Binding var showingPreviousAnswers: Bool
    
    var body: some View {
        Button(action: {
            showingPreviousAnswers = true
        }) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.accent)
                    .font(.title2)
                
                Text("Geçmiş Cevaplarını Gör")
                    .font(.headline)
                    .foregroundColor(.accent)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.accent)
            }
            .padding()
            .secondaryButtonStyle()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Save Button
struct SaveButton: View {
    @ObservedObject var viewModel: MainViewModel
    
    var body: some View {
        Button(action: {
            viewModel.saveAnswer()
        }) {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                }
                
                Text(viewModel.hasAnsweredToday ? "Güncelle" : "Kaydet")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .primaryButtonStyle()
        }
        .disabled(!viewModel.canSave)
        .opacity(viewModel.canSave ? 1.0 : 0.6)
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previous Answers Sheet
struct PreviousAnswersSheet: View {
    @ObservedObject var viewModel: MainViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(viewModel.previousYearAnswers) { answer in
                        PreviousAnswerCard(answer: answer)
                    }
                }
                .padding()
            }
            .navigationTitle("Geçmiş Cevaplarım")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(trailing: Button("Kapat") { dismiss() })
        }
    }
}

// MARK: - Previous Answer Card
struct PreviousAnswerCard: View {
    let answer: Answer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("\(answer.yearFromDate) yılından")
                    .font(.headline)
                    .foregroundColor(.accent)
                
                Spacer()
                
                if let emoji = answer.emoji {
                    Text(emoji)
                        .font(.title2)
                }
                
                if answer.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.favoriteRed)
                }
            }
            
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
                    
                    Text(formattedDate(answer.date))
                        .font(.caption)
                        .foregroundColor(.secondaryText)
                }
            }
        }
        .padding()
        .cardStyle()
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

struct TodayView_Previews: PreviewProvider {
    static var previews: some View {
        TodayView(viewModel: MainViewModel.sampleViewModel())
    }
}
