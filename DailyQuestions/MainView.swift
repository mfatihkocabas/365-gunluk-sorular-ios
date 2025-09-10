import SwiftUI
import Foundation

struct MainView: View {
    @State private var showTutorial = !UserDefaults.standard.bool(forKey: "hasSeenTutorial")
    
    var body: some View {
        TabView {
            TodayViewExact()
                .tabItem {
                    Image(systemName: "circle.fill")
                    Text("Günün Sorusu")
                }
            
            FavoritesViewExact()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoriler")
                }
            
            CalendarViewExact()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Geçmiş")
                }
            
            SettingsViewExact()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profil")
                }
        }
        .accentColor(Color(red: 1.0, green: 0.27, blue: 0.27))
        .fullScreenCover(isPresented: $showTutorial) {
            TutorialView(isPresented: $showTutorial)
        }
        .onAppear {
            if showTutorial {
                UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
            }
        }
    }
}

// MARK: - Calendar View
struct CalendarViewExact: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var currentDate = Date()
    private let weekDays = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    
    private var currentMonth: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentDate)
    }
    
    private var calendarDays: [Int] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: currentDate)!
        return Array(range)
    }
    
    private var firstWeekday: Int {
        let calendar = Calendar.current
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
        return calendar.component(.weekday, from: firstDayOfMonth) - 1
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Geçmiş")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Invisible button for balance
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            // Month Header
            HStack {
                Button(action: {
                    goToPreviousMonth()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text(currentMonth)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                Button(action: {
                    goToNextMonth()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            // Week Days Header
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 15)
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            // Calendar Grid
            VStack(spacing: 8) {
                let totalDays = calendarDays.count + firstWeekday
                let totalWeeks = (totalDays + 6) / 7
                
                ForEach(0..<totalWeeks, id: \.self) { weekIndex in
                    HStack(spacing: 8) {
                        ForEach(0..<7, id: \.self) { dayIndex in
                            let dayNumber = (weekIndex * 7) + dayIndex - firstWeekday + 1
                            
                            if dayNumber > 0 && dayNumber <= calendarDays.count {
                                let dayDate = getDateForDay(dayNumber)
                                let isAnswered = viewModel.isDayAnswered(dayDate)
                                let isToday = Calendar.current.isDate(dayDate, inSameDayAs: Date())
                                
                                Button(action: {
                                    // Day tapped action
                                }) {
                                    Text("\(dayNumber)")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(isToday ? .white : .black)
                                        .frame(width: 40, height: 40)
                                        .background(
                                            isToday ? Color(red: 1.0, green: 0.27, blue: 0.27) :
                                            isAnswered ? Color.green.opacity(0.3) :
                                            Color(red: 0.99, green: 0.98, blue: 0.96)
                                        )
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(
                                                    isAnswered ? Color.green : Color.gray.opacity(0.2), 
                                                    lineWidth: isAnswered ? 2 : 1
                                                )
                                        )
                                }
                                .disabled(isAnswered) // Disable answered days
                            } else {
                                Color.clear
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            // Lock Section
            VStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                
                Text("Cevap Kilitli")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Text("Bu tarihteki cevabını görmek için 1 yıl beklemelisin.")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .padding(.vertical, 30)
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            Spacer()
        }
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadAnsweredDays()
        }
    }
    
    // MARK: - Helper Functions
    private func goToPreviousMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func goToNextMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
            currentDate = newDate
        }
    }
    
    private func getDateForDay(_ day: Int) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        var dateComponents = components
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? Date()
    }
}

// MARK: - Settings View
struct SettingsViewExact: View {
    @State private var isNotificationsEnabled = true
    @State private var showingAboutSheet = false
    @State private var showingTutorial = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Text("Profil")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Invisible button for balance
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.clear)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            // Settings Content
            ScrollView {
                VStack(spacing: 20) {
                    // Profil Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Profil")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Kullanıcı")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Text("Günlük düşünce yazarı")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)
                    }
                    
                    // Bildirimler Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Bildirimler")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        HStack(spacing: 12) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Bildirimler")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black)
                                
                                Text("Favori sorular için hatırlatma")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $isNotificationsEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Color(red: 1.0, green: 0.27, blue: 0.27)))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .padding(.horizontal, 20)
                    }
                    
                    // Uygulama Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Uygulama")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                            .padding(.horizontal, 20)
                        
                        VStack(spacing: 8) {
                            // Hakkında
                            Button(action: { showingAboutSheet = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Hakkında")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        
                                        Text("Uygulama detayları ve bilgiler")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            
                            // Tutorial
                            Button(action: { showingTutorial = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(Color(red: 1.0, green: 0.27, blue: 0.27))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Nasıl Kullanılır?")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.black)
                                        
                                        Text("Tutorial'ı tekrar izleyin")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            
                            // Tüm Verileri Sil
                            Button(action: {}) {
                                HStack(spacing: 12) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.red)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Tüm Verileri Sil")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.red)
                                        
                                        Text("Dikkat: Bu işlem geri alınamaz")
                                            .font(.system(size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 20)
            }
            .background(Color(red: 0.99, green: 0.98, blue: 0.96))
            
            Spacer()
        }
        .background(Color(red: 0.99, green: 0.98, blue: 0.96))
        .sheet(isPresented: $showingAboutSheet) {
            AboutSheet()
        }
        .fullScreenCover(isPresented: $showingTutorial) {
            TutorialView(isPresented: $showingTutorial)
        }
    }
}

#Preview {
    MainView()
}