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
    
    @State private var dateSheet: Bool = false
    @State private var todayTrigger: Bool = false
    
    var body: some View {
        TabView(selection: $offset) {
            MealView(
                date: targetDate,
                type: .breakfast,
                menu: meal?.breakfast,
                dateSheet: $dateSheet,
                todayTrigger: $todayTrigger
            ).tag(0)
            MealView(
                date: targetDate,
                type: .lunch,
                menu: meal?.lunch,
                dateSheet: $dateSheet,
                todayTrigger: $todayTrigger
            ).tag(1)
            MealView(
                date: targetDate,
                type: .dinner,
                menu: meal?.dinner,
                dateSheet: $dateSheet,
                todayTrigger: $todayTrigger
            ).tag(2)
        }
        .onChange(of: todayTrigger) {
            today()
        }
        .onChange(of: targetDate) {
            update(targetDate)
        }
        .onAppear {
            todayTrigger.toggle()
        }
        .sheet(isPresented: $dateSheet) {
            PopupView(targetDate: $targetDate, todayTrigger: $todayTrigger)
        }
    }
    
    private func today() {
        let current = MealHelper.current(viewContext)
        targetDate = DateHelper.formatToDate(current.date)
        offset = current.target.typeIndex
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

struct PopupView: View {
    @Binding var targetDate: Date
    @Binding var todayTrigger: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                todayTrigger.toggle()
            }) {
                Text(DateHelper.formatString(targetDate))
                    .font(.title3)
            }
            .buttonStyle(.plain)
            Spacer()
            HStack {
                Button(action: {
                    targetDate = DateHelper.previousDay(targetDate)
                }) {
                    Text("이전")
                }
                Button(action: {
                    targetDate = DateHelper.nextDay(targetDate)
                }) {
                    Text("다음")
                }
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

