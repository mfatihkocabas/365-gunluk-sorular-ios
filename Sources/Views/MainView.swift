import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MainViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "doc.text")
                    Text("Günün Sorusu")
                }
                .tag(0)
            
            HistoryView()
                .tabItem {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Geçmiş")
                }
                .tag(1)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Takvim")
                }
                .tag(2)
            
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favoriler")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Ayarlar")
                }
                .tag(4)
        }
        .accentColor(.accent)
        .onAppear {
            NotificationManager.shared.requestPermission()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
