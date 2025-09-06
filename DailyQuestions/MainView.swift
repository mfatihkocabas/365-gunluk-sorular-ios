import SwiftUI

struct MainView: View {
    var body: some View {
        TabView {
            TodayViewSimple()
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Günün Sorusu")
                }
            
            Text("Geçmiş")
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Geçmiş")
                }
            
            Text("Takvim")
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Takvim")
                }
            
            Text("Favoriler")
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoriler")
                }
            
            Text("Ayarlar")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Ayarlar")
                }
        }
        .accentColor(.blue)
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
