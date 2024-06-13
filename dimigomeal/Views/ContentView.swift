//
//  ContentView.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var isShowingDetailView = false
    @State private var offset = CGFloat.zero
    
    @State private var targetDate = Date()
    @State private var isLoading = false
    @State private var meal: MealEntity? = nil
    @Environment(\.managedObjectContext) private var viewContext
    
    @AppStorage("theme/background") private var backgroundTheme = BackgroundTheme.dynamic
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Button(action: today) {
                                VStack {
                                    Text("\(formattedDateString(targetDate))")
                                        .foregroundColor(Color("Color"))
                                        .font(.custom("SUIT-Bold", size: 20))
                                }
                            }
                            .buttonStyle(TriggerButton())
                            .frame(maxWidth: .infinity)
                            NavigationLink(destination: SettingsView()) {
                                VStack {
                                    Image("Menu")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .buttonStyle(TriggerButton())
                            .frame(width: 56)
                        }
                        .padding(.horizontal, 16)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                MealView(type: .breakfast, meal: meal?.breakfast)
                                MealView(type: .lunch, meal: meal?.lunch)
                                MealView(type: .dinner, meal: meal?.dinner)
                            }
                            .background(GeometryReader { proxy -> Color in
                                DispatchQueue.main.async {
                                    offset = max(0, min(2, -proxy.frame(in: .named("scroll")).origin.x / UIScreen.main.bounds.width))
                                }
                                return Color.clear
                            })
                        }
                        .scrollClipDisabled()
                        .coordinateSpace(name: "scroll")
                        .frame(maxHeight: .infinity)
                        .scrollTargetBehavior(.paging)
                        HStack(spacing: 16) {
                            Button(action: previous) {
                                VStack {
                                    Image("Left")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .buttonStyle(TriggerButton())
                            Button(action: next) {
                                VStack {
                                    Image("Right")
                                        .resizable()
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .buttonStyle(TriggerButton())
                        }
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 16)
                }
            }
            .background(
                ZStack {
                    Color("Background")
                    backgroundTheme == BackgroundTheme.dynamic ? ZStack {
                        Group {
                            Image("Dinner")
                                .resizable()
                            Image("Lunch")
                                .resizable()
                                .mask(
                                    Rectangle()
                                        .edgesIgnoringSafeArea(.all)
                                        .offset(x: UIScreen.main.bounds.width * max(0, min(1, offset - 1)) * -1)
                                )
                            Image("Breakfast")
                                .resizable()
                                .mask(
                                    Rectangle()
                                        .edgesIgnoringSafeArea(.all)
                                        .offset(x: UIScreen.main.bounds.width * max(0, min(1, offset)) * -1)
                                )
                        }
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    } : nil
                }
                    .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                update(for: targetDate)
            }
            .onChange(of: targetDate) { _, newDate in
                update(for: newDate)
            }
        }
    }
    
    private func formattedDateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func today() {
        targetDate = Date()
    }
    
    private func previous() {
        targetDate = Calendar.current.date(byAdding: .day, value: -1, to: targetDate)!
    }
    
    private func next() {
        targetDate = Calendar.current.date(byAdding: .day, value: 1, to: targetDate)!
    }
    
    private func update(for date: Date) {
        let meal = fetchMeal(for: formattedDate(date))
        if let meal = meal {
            self.meal = meal
        } else {
            self.meal = nil
            isLoading = true
        }
        
        fetchMealFromAPI(for: formattedDate(date))
    }
    
    private func fetchMealFromAPI(for date: String) {
        let url = URL(string: "https://api.디미고급식.com/week?date=\(date)")!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            guard let data = data, error == nil else {
                print("Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let meals = try JSONDecoder().decode([MealAPIResponse].self, from: data)
                for mealData in meals {
                    saveMeal(mealData)
                }
                
                DispatchQueue.main.async {
                    self.meal = fetchMeal(for: date)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    private func saveMeal(_ mealData: MealAPIResponse) {
        if let meal = fetchMeal(for: mealData.date) {
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

    private func fetchMeal(for date: String) -> MealEntity? {
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        ContentView()
            .environment(\.managedObjectContext, context)
    }
}
