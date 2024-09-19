//
//  DimigoMealWatchApp.swift
//  DimigoMealWatch
//
//  Created by noViceMin on 9/19/24.
//

import SwiftUI

@main
struct DimigoMealWatchApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
