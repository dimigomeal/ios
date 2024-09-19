//
//  MealHelper.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-14.
//

import SwiftUI
import CoreData

struct MealHelper {
    static func current(_ viewContext: NSManagedObjectContext) -> Current {
        var targetDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: targetDate)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        
        var type: MealType
        let totalMinutes = hour * 60 + minute
        switch totalMinutes {
        case 0..<480: // 00:00 - 08:00
            type = .breakfast
        case 480..<810: // 08:00 - 13:30
            type = .lunch
        case 810..<1170: // 13:30 - 19:30
            type = .dinner
        default:
            type = .breakfast
            targetDate = Calendar.current.date(byAdding: .day, value: 1, to: targetDate)!
        }
        
        let date = DateHelper.format(targetDate)
        var menu = ""
        if let meal = get(viewContext, date) {
            switch type {
            case .breakfast:
                menu = meal.breakfast ?? ""
            case .lunch:
                menu = meal.lunch ?? ""
            case .dinner:
                menu = meal.dinner ?? ""
            }
        }
        
        let typeIndex = MealType.allCases.firstIndex(of: type)!
        
        return Current(type: type, typeIndex: typeIndex, date: date, menu: menu)
    }
    
    static func get(_ viewContext: NSManagedObjectContext, _ date: String) -> MealEntity? {
        let request: NSFetchRequest<MealEntity> = MealEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as CVarArg)
        
        do {
            let results = try viewContext.fetch(request)
            if let meal = results.first {
                return meal
            } else {
                return nil
            }
        } catch {
            print("Failed to fetch meal from Core Data: \(error)")
            return nil
        }
    }
    
    static func save(_ viewContext: NSManagedObjectContext, _ mealData: MealAPIResponse) {
        if let meal = get(viewContext, mealData.date) {
            meal.breakfast = mealData.breakfast
            meal.lunch = mealData.lunch
            meal.dinner = mealData.dinner
            do {
                try viewContext.save()
            } catch {
                print(meal)
                print("Failed to update meal: \(error)")
            }
        } else {
            let meal = MealEntity(context: viewContext)
            meal.date = mealData.date
            meal.breakfast = mealData.breakfast
            meal.lunch = mealData.lunch
            meal.dinner = mealData.dinner
            
            do {
                try viewContext.save()
            } catch {
                print(meal)
                print("Failed to save meal: \(error)")
            }
        }
    }
}
