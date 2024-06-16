//
//  ContentView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var targetDate = Date()
    @State private var offset = CGFloat.zero
    @State private var offsetIndex: Int = -1
    @State private var meal: MealEntity? = nil
    
    @AppStorage("theme/background") private var backgroundTheme = BackgroundTheme.dynamic
    @AppStorage("effect/transform") private var transformEffect = TransformEffect.slide
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        Button(action: today) {
                            VStack {
                                Text("\(DateHelper.formatString(targetDate))")
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
                    ScrollViewReader { scrollProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                MealView(type: .breakfast, menu: meal?.breakfast)
                                    .id(0)
                                MealView(type: .lunch, menu: meal?.lunch)
                                    .id(1)
                                MealView(type: .dinner, menu: meal?.dinner)
                                    .id(2)
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
                        .onChange(of: offsetIndex) {
                            scrollProxy.scrollTo(offsetIndex, anchor: .leading)
                            offsetIndex = -1
                        }
                    }
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
            .background(
                ZStack {
                    Color("Background")
                    backgroundTheme == BackgroundTheme.dynamic ? ZStack {
                        switch transformEffect {
                        case .slide:
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
                        case .fade:
                            Group {
                                Image("Dinner")
                                    .resizable()
                                Image("Lunch")
                                    .resizable()
                                    .opacity(Double(max(0, min(1, 2 - offset))))
                                Image("Breakfast")
                                    .resizable()
                                    .opacity(Double(max(0, min(1, 1 - offset))))
                            }
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        }
                    } : nil
                }
                    .edgesIgnoringSafeArea(.all)
            )
            .onAppear {
                today()
                
                Task {
                    await LiveActivityHelper.reload(viewContext)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                Task {
                    await LiveActivityHelper.reload(viewContext)
                }
            }
        }
    }
    
    private func today() {
        let current = MealHelper.current(viewContext)
        targetDate = DateHelper.formatToDate(current.date)
        offsetIndex = MealType.allCases.firstIndex(of: current.type)!
        update(targetDate)
    }
    
    private func previous() {
        targetDate = Calendar.current.date(byAdding: .day, value: -1, to: targetDate)!
        update(targetDate)
    }
    
    private func next() {
        targetDate = Calendar.current.date(byAdding: .day, value: 1, to: targetDate)!
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
    @AppStorage("theme/color") private var colorTheme = ColorTheme.system
    
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
