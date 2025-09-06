import Foundation
import SwiftUI

// MARK: - Calendar Extensions
extension Calendar {
    func dayOfYear(for date: Date) -> Int? {
        return self.ordinality(of: .day, in: .year, for: date)
    }
    
    func dateFromDayOfYear(_ dayOfYear: Int, year: Int = Calendar.current.component(.year, from: Date())) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.day = dayOfYear
        return calendar.date(from: dateComponents)
    }
}

// MARK: - Date Extensions
extension Date {
    var dayOfYear: Int {
        Calendar.current.dayOfYear(for: self) ?? 1
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    func isSameDay(as date: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: date)
    }
    
    func yearsAgo(_ years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: -years, to: self) ?? self
    }
    
    func oneYearAgo() -> Date {
        yearsAgo(1)
    }
    
    static func startOfYear(_ year: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = 1
        components.day = 1
        return Calendar.current.date(from: components) ?? Date()
    }
}

// MARK: - String Extensions
extension String {
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var isNotEmpty: Bool {
        !self.trimmed.isEmpty
    }
}

// MARK: - Color Extensions
extension Color {
    static let primaryBackground = Color("PrimaryBackground")
    static let secondaryBackground = Color("SecondaryBackground")
    static let primaryText = Color("PrimaryText")
    static let secondaryText = Color("SecondaryText")
    static let accent = Color("AccentColor")
    static let favoriteRed = Color.red
    static let successGreen = Color.green
}

// MARK: - View Extensions
extension View {
    func cardStyle() -> some View {
        self
            .background(Color.secondaryBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding()
            .background(Color.accent)
            .cornerRadius(10)
    }
    
    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(.accent)
            .padding()
            .background(Color.secondaryBackground)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.accent, lineWidth: 1)
            )
    }
}
