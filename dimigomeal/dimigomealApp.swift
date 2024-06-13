//
//  dimigomealApp.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI

@main
struct dimigomealApp: App {
    @AppStorage("theme/color") private var colorTheme = ColorTheme.system
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            .preferredColorScheme(colorTheme.scheme)
        }
    }
}
