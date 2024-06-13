//
//  ContentView.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI
import CoreData

struct BackdropView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView()
        let blur = UIBlurEffect()
        let animator = UIViewPropertyAnimator()
        animator.addAnimations { view.effect = blur }
        animator.fractionComplete = 0
        animator.stopAnimation(false)
        animator.finishAnimation(at: .current)
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) { }
}

struct BackdropBlurView: View {
    let radius: CGFloat
    
    @ViewBuilder
    var body: some View {
        BackdropView()
            .blur(radius: radius, opaque: true)
            .background(Color("ViewBackground"))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color("ViewBorder"), lineWidth: 3)
            )
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 0)
    }
}

enum MealType {
    case breakfast
    case lunch
    case dinner
}

struct MealView: View {
    let type: MealType
    let meal: String?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        Image(type == .breakfast ? "BreakfastIcon" : type == .lunch ? "LunchIcon" : "DinnerIcon")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text(type == .breakfast ? "아침" : type == .lunch ? "점심" : "저녁")
                            .foregroundColor(Color("Color"))
                            .font(.custom("SUIT-Bold", size: 32))
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach("\(meal ?? "급식 정보가 없습니다")".components(separatedBy: "/"), id: \.self) { item in
                            HStack {
                                Text("•")
                                    .foregroundColor(Color("Color"))
                                    .font(.custom("SUIT-Medium", size: 20))
                                Text(item)
                                    .foregroundColor(Color("Color"))
                                    .font(.custom("SUIT-Medium", size: 20))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(17)
            }
            .padding(3)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(BackdropBlurView(radius: 48))
        }
        .padding(.horizontal, 16)
        .frame(width: UIScreen.main.bounds.width)
        .frame(maxHeight: .infinity)
    }
}

struct TriggerButton: PrimitiveButtonStyle {
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        MyButton(configuration: configuration)
    }

    struct MyButton: View {
        @State private var pressed = false
        @State private var skip = false

        let configuration: PrimitiveButtonStyle.Configuration
        
        var body: some View {
            GeometryReader { proxy in
                return configuration.label
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(BackdropBlurView(radius: 20))
                    .opacity(pressed ? 0.6 : 1)
                    .shadow(color: Color.black.opacity(pressed ? 0.2 : 0.05), radius: 14, x: 0, y: 0)
                    .scaleEffect(pressed ? 1.02 : 1)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if value.location.x < 0 || value.location.x > proxy.size.width || value.location.y < 0 || value.location.y > proxy.size.height {
                                    skip = true
                                } else {
                                    skip = false
                                }
                            }
                    )
                    .onLongPressGesture(minimumDuration: 0, pressing: { value in
                        withAnimation(.easeInOut(duration: 0.1)) {
                            pressed = value
                        }
                    }, perform: {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    })
                    .onChange(of: pressed) { _, value in
                        if !value {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            
                            if !skip {
                                configuration.trigger()
                                skip = false
                            }
                        }
                    }
            }
            .frame(height: 56)
        }
    }
}

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
            print("없다 이놈아")
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

extension DateFormatter {
    static let apiDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

struct MealAPIResponse: Codable {
    let breakfast: String
    let date: String
    let dinner: String
    let lunch: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.shared.container.viewContext
        ContentView()
            .environment(\.managedObjectContext, context)
    }
}

#Preview {
    @Previewable @AppStorage("theme/color") var colorTheme = ColorTheme.system
    
    NavigationView {
        ContentView()
    }
    .preferredColorScheme(colorTheme.scheme)
}
