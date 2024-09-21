//
//  LiveActivityAttributes.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-16.
//
import ActivityKit

struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var type: MealType
        var menu: String?
        var date: String
    }
    
    var theme: WidgetTheme
}
