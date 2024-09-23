//
//  MealModel.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-13.
//

import Foundation

enum MealType: String, Codable, CaseIterable {
    case breakfast
    case lunch
    case dinner
}

struct MealAPIResponse: Codable {
    let date: String
    let breakfast: String
    let lunch: String
    let dinner: String
}

struct Target: Codable {
    let type: MealType
    let typeIndex: Int
    let date: Date
}

struct Current: Codable {
    let date: String
    let menu: String
    let target: Target
}

let dummyMeal = MealAPIResponse(
    date: "2022-08-18",
    breakfast: "소고기메추리알장조림/쌀밥/콩가루배추국/한입김치전*양념장/콩나물무침/오이김치/치즈앤치즈/유산균/2종과일/2종시리얼/우유,두유,저지방우유,2종주스 중 택1/간편식(로제치킨샌드위치,케이준치킨샐러드,선식)",
    lunch: "중화비빔밥*계란후라이/북어무국/탕수육/반달단무지/치커리유자무침/배추김치/피크닉",
    dinner: "고추장제육삼겹구이/수수밥/쌀밥/감자옹심이국/두부구이*양념장/상추겉절이/포기김치/젤리뽀/비빔코너/간편식(구운연어샐러드,선식)"
)
