import SwiftUI

struct TutorialView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    private let tutorialPages = [
        TutorialPage(
            icon: "book.circle.fill",
            title: "365 Günlük Sorular'a Hoş Geldiniz!",
            description: "Her gün bir soru ile düşüncelerinizi kaydedin ve bir yıl sonra nasıl değiştiğinizi görün.",
            color: Color(red: 1.0, green: 0.27, blue: 0.27)
        ),
        TutorialPage(
            icon: "calendar",
            title: "Günlük Sorular",
            description: "Her gün uygulamayı açın ve o günün özel sorusunu görün. 365 benzersiz soru ile kişisel gelişim yolculuğunuza başlayın.",
            color: .blue
        ),
        TutorialPage(
            icon: "pencil",
            title: "Cevabınızı Yazın",
            description: "Düşüncelerinizi, duygularınızı ve deneyimlerinizi kaydedin. Her cevap sizin kişisel tarihinizin bir parçası.",
            color: .green
        ),
        TutorialPage(
            icon: "heart.fill",
            title: "Favori Sorular",
            description: "Önemli soruları favorilere ekleyin. Bu sorular için 1 yıl sonra hatırlatma bildirimi alacaksınız.",
            color: Color(red: 1.0, green: 0.27, blue: 0.27)
        ),
        TutorialPage(
            icon: "clock.arrow.circlepath",
            title: "Zaman Kapsülü",
            description: "1 yıl sonra aynı soruyu tekrar görün ve geçmiş cevaplarınızı karşılaştırın. Değişiminizi fark edin!",
            color: .purple
        ),
        TutorialPage(
            icon: "chart.bar.fill",
            title: "İstatistikler",
            description: "Cevaplarınızın analizi ve görselleştirmesi ile kişisel gelişiminizi takip edin.",
            color: .orange
        )
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.99, green: 0.98, blue: 0.96)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    Button("Atla") {
                        isPresented = false
                    }
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
                    .padding(.top, 10)
                }
                
                // Tutorial Content
                TabView(selection: $currentPage) {
                    ForEach(0..<tutorialPages.count, id: \.self) { index in
                        TutorialPageView(page: tutorialPages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom Controls
                VStack(spacing: 20) {
                    // Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<tutorialPages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color(red: 1.0, green: 0.27, blue: 0.27) : Color.gray.opacity(0.3))
                                .frame(width: 8, height: 8)
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    
                    // Navigation Buttons
                    HStack(spacing: 20) {
                        if currentPage > 0 {
                            Button("Geri") {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .cornerRadius(25)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                        
                        Spacer()
                        
                        Button(currentPage == tutorialPages.count - 1 ? "Başla" : "İleri") {
                            if currentPage == tutorialPages.count - 1 {
                                isPresented = false
                            } else {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Color(red: 1.0, green: 0.27, blue: 0.27))
                        .cornerRadius(25)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
        }
    }
}

struct TutorialPageView: View {
    let page: TutorialPage
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundColor(page.color)
                .padding(.bottom, 20)
            
            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
        }
    }
}

struct TutorialPage {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct TutorialView_Previews: PreviewProvider {
    static var previews: some View {
        TutorialView(isPresented: .constant(true))
    }
}
