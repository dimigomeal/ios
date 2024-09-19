//
//  ContentView.swift
//  DimigoMealWatch
//
//  Created by noViceMin on 9/19/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var targetDate = Date()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        
        ForEach(ColorScheme.allCases, id: \.self) { scheme in
            NavigationView {
                ContentView()
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .preferredColorScheme(scheme)
        }
    }
}
