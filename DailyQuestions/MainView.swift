import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            TodayViewDesigned()
                .tabItem {
                    Image(systemName: "doc.text.fill")
                    Text("Günün Sorusu")
                }
            
            Text("Favoriler")
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoriler")
                }
            
            Text("Geçmiş")
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Geçmiş")
                }
            
            Text("Profil")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
        }
        .accentColor(Color(red: 0.9, green: 0.3, blue: 0.3))
    }
}

struct TodayViewDesigned: View {
    @State private var answerText = ""
    @State private var isFavorite = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Günün Sorusu")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Date
                        Text("24 Haziran 2024")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.top, 20)
                        
                        // Main Question
                        Text("Hayatınızda şu anda en\nönemli olan şey nedir?")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 30)
                            .padding(.top, 15)
                        
                        // Answer Text Area
                        VStack(alignment: .leading, spacing: 0) {
                            if answerText.isEmpty {
                                Text("Cevabınızı buraya yazın...")
                                    .font(.body)
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                
                                Spacer()
                            }
                            
                            TextEditor(text: $answerText)
                                .font(.body)
                                .scrollContentBackground(.hidden)
                                .padding(.horizontal, 12)
                                .padding(.vertical, answerText.isEmpty ? 0 : 16)
                        }
                        .frame(height: 200)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 30)
                        
                        // Bottom Action Area
                        HStack {
                            // Favorite Button
                            Button(action: {
                                isFavorite.toggle()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .font(.title3)
                                        .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                                    
                                    Text("Favorilere Ekle")
                                        .font(.body)
                                        .foregroundColor(.black)
                                }
                            }
                            
                            Spacer()
                            
                            // Save Button
                            Button(action: {
                                print("Cevap kaydedildi: \(answerText)")
                            }) {
                                Text("Kaydet")
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 12)
                                    .background(Color(red: 0.9, green: 0.3, blue: 0.3))
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 20)
                        
                        // Time Capsule Link
                        Button(action: {}) {
                            HStack(spacing: 8) {
                                Image(systemName: "infinity")
                                    .font(.body)
                                    .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                                
                                Text("Zaman Kapsülünü Aratac Geçen Yıl\nNe Dedin?")
                                    .font(.body)
                                    .foregroundColor(Color(red: 0.9, green: 0.3, blue: 0.3))
                                    .multilineTextAlignment(.leading)
                                    .lineSpacing(2)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 25)
                        
                        Spacer(minLength: 80)
                    }
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.94, blue: 0.92),
                        Color(red: 0.96, green: 0.92, blue: 0.90)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

struct TodayViewSimple: View {
    @State private var answerText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Tarih
                    Text("24 Haziran 2024, Pazartesi")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Gün 176")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // Soru Kartı
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            Text("Bugünün Sorusu")
                                .font(.headline)
                            
                            Spacer()
                        }
                        
                        Text("Hayatınızda şu anda en önemli olan şey nedir?")
                            .font(.title3)
                            .fontWeight(.medium)
                            .lineLimit(nil)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Cevap Alanı
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            Text("Cevabını Yaz")
                                .font(.headline)
                            
                            Spacer()
                        }
                        
                        TextEditor(text: $answerText)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Kaydet Butonu
                    Button(action: {
                        print("Cevap kaydedildi: \(answerText)")
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                            
                            Text("Kaydet")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Günün Sorusu")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
