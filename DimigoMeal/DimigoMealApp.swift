//
//  DimigoMealApp.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI

@main
struct DimigoMealApp: App {
    let persistenceController = PersistenceController.shared
    @AppStorage("theme/color") private var colorTheme = ColorTheme.system
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .navigationViewStyle(.stack)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .preferredColorScheme(colorTheme.scheme)
        }
    }
}
