//
//  StringHelper.swift
//  DimigoMeal
//
//  Created by noViceMin on 9/19/24.
//

import Foundation

struct StringHelper {
    static func getTypeString(_ type: MealType) -> String {
        switch type {
        case .breakfast:
            "아침"
        case .lunch:
            "점심"
        case .dinner:
            "저녁"
        }
    }
    
    static func getMealArray(_ menu: String?) -> [String] {
        guard let menu = menu else {
            return ["급식 정보가 없습니다"]
        }
        
        do {
            let regex = try NSRegularExpression(pattern: "/(?![^()]*\\))", options: [])
            let range = NSRange(menu.startIndex..<menu.endIndex, in: menu)
            let results = regex.matches(in: menu, options: [], range: range)
            
            var lastEndIndex = menu.startIndex
            var components: [String] = []
            
            for result in results {
                let matchRange = Range(result.range, in: menu)!
                components.append(String(menu[lastEndIndex..<matchRange.lowerBound]))
                lastEndIndex = matchRange.upperBound
            }
            
            components.append(String(menu[lastEndIndex..<menu.endIndex]))
            
            return components
        } catch {
            print("Invalid regex pattern")
            return [menu]
        }
    }
}
