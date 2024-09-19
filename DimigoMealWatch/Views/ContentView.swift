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
    @State private var offset = 1
    @State private var meal: MealEntity? = nil
    
    var body: some View {
        TabView(selection: $offset) {
            MealView(date: targetDate, type: .breakfast, menu: meal?.breakfast)
                .tag(0)
            MealView(date: targetDate, type: .lunch, menu: meal?.lunch)
                .tag(1)
            MealView(date: targetDate, type: .dinner, menu: meal?.dinner)
                .tag(2)
        }
        .onAppear {
            today()
        }
    }
    
    private func today() {
        let current = MealHelper.current(viewContext)
        targetDate = DateHelper.formatToDate(current.date)
        offset = current.typeIndex
        update(targetDate)
    }
    
    private func update(_ date: Date) {
        self.meal = MealHelper.get(viewContext, DateHelper.format(date))
        
        Task {
            if let meals = await EndpointHelper.fetch(DateHelper.format(date)) {
                for meal in meals {
                    MealHelper.save(viewContext, meal)
                }
            }
            
            if(self.meal == nil) {
                self.meal = MealHelper.get(viewContext, DateHelper.format(date))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        
        NavigationView {
            ContentView()
        }
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}

