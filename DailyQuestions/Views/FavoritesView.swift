import SwiftUI

struct FavoritesViewExact: View {
    @State private var favoriteQuestions: [(question: Question, date: Date)] = []
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    selectedTab = 0 // Ana sayfaya dön
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Favoriler")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            // Favorites List
            ScrollView {
                LazyVStack(spacing: 0) {
                    if favoriteQuestions.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "heart")
                                .font(.system(size: 48))
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Text("Henüz favori sorunuz yok")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Text("Soruları favorilere ekleyerek\nbir yıl sonra bildirim alabilirsiniz")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(favoriteQuestions.indices, id: \.self) { index in
                            let favoriteItem = favoriteQuestions[index]
                            
                            VStack(spacing: 0) {
                                HStack(alignment: .top, spacing: 12) {
                                    Button(action: {}) {
                                        Image(systemName: "bell.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 4)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(favoriteItem.question.text)
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(3)
                                        
                                        Text(formatDate(favoriteItem.date))
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        DataManager.shared.removeQuestionFromFavorites(favoriteItem.question.id)
                                        favoriteQuestions = DataManager.shared.getFavoriteQuestionsWithDetails()
                                    }) {
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                                    }
                                    .padding(.top, 4)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color(red: 0.99, green: 0.98, blue: 0.96))
                                
                                if index < favoriteQuestions.count - 1 {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 1)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.top, 10)
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            Spacer()
        }
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
        .navigationBarHidden(true)
        .onAppear {
            favoriteQuestions = DataManager.shared.getFavoriteQuestionsWithDetails()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    FavoritesViewExact(selectedTab: .constant(0))
}
