//
//  PersistenceController.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-13.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)

        return controller
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MealModel")
        let url = URL.storeURL(for: "group.kr.isamin.dimigomeal.data", databaseName: "MealModel")
        let storeDescription = NSPersistentStoreDescription(url: url)
        container.persistentStoreDescriptions = [storeDescription]

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

public extension URL {
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Unable to create URL for \(appGroup)")
        }
        
        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
