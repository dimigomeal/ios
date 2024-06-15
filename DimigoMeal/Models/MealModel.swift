//
//  MealModel.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-13.
//

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
}

struct MealAPIResponse: Codable {
    let breakfast: String
    let date: String
    let dinner: String
    let lunch: String
}

struct Current: Codable {
    let type: MealType
    let date: String
    let menu: String
}
