//
//  DateHelper.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-14.
//

import Foundation

struct DateHelper {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    static func format(_ date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    static func formatString(_ date: Date) -> String {
        dateFormatter.dateFormat = "M월 d일 EEEE"
        return dateFormatter.string(from: date)
    }
    
    static func formatShortString(_ date: Date) -> String {
        dateFormatter.dateFormat = "M월 d일 E"
        return dateFormatter.string(from: date)
    }
    
    static func formatToStringFormat(_ date: String) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date) ?? Date()
        dateFormatter.dateFormat = "M월 d일 EEEE"
        return dateFormatter.string(from: date)
    }
    
    static func formatToDate(_ date: String) -> Date {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: date) ?? Date()
    }
    
    static func nextDay(_ date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 1, to: date)!
    }
    
    static func previousDay(_ date: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -1, to: date)!
    }
}
