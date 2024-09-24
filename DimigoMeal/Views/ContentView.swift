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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State private var targetDate = MealHelper.target().date
    @State private var offset = MealHelper.target().typeIndex
    @State private var meal: MealEntity? = nil
    
    @State private var width: CGFloat = UIScreen.main.bounds.width
    @State private var height: CGFloat = UIScreen.main.bounds.height
    
    @AppStorage("theme/background") private var backgroundTheme = BackgroundTheme.dynamic
    @AppStorage("effect/transform") private var transformEffect = TransformEffect.slide
    
    var offsetObserver = PageOffsetObserver(offset: UIScreen.main.bounds.width * Double(MealHelper.target().typeIndex))
    var body: some View {
        GeometryReader { geometry in
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
                            Group {
                                NavigationLink(destination: SettingsView()) {
                                    VStack {
                                        Image("Menu")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .buttonStyle(TriggerButton())
                                if horizontalSizeClass != .compact {
                                    Button(action: {
                                        targetDate = DateHelper.previousDay(targetDate)
                                    }) {
                                        VStack {
                                            Image("Left")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                        }
                                    }
                                    .buttonStyle(TriggerButton())
                                    Button(action: {
                                        targetDate = DateHelper.nextDay(targetDate)
                                    }) {
                                        VStack {
                                            Image("Right")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                        }
                                    }
                                    .buttonStyle(TriggerButton())
                                }
                            }
                            .frame(width: 56)
                        }
                        .padding(.horizontal, 16)
                        TabView(selection: $offset) {
                            HStack(spacing: -16) {
                                MealView(type: .breakfast, menu: meal?.breakfast)
                                    .tag(0)
                                if horizontalSizeClass != .compact {
                                    MealView(type: .lunch, menu: meal?.lunch)
                                        .tag(1)
                                    MealView(type: .dinner, menu: meal?.dinner)
                                        .tag(2)
                                }
                            }
                            .background {
                                if !offsetObserver.isObserving {
                                    FindCollectionView {
                                        offsetObserver.collectionView = $0
                                        offsetObserver.observe()
                                    }
                                }
                            }
                            if horizontalSizeClass == .compact {
                                MealView(type: .lunch, menu: meal?.lunch)
                                    .tag(1)
                                MealView(type: .dinner, menu: meal?.dinner)
                                    .tag(2)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        if horizontalSizeClass == .compact {
                            HStack(spacing: 16) {
                                Button(action: {
                                    targetDate = DateHelper.previousDay(targetDate)
                                }) {
                                    VStack {
                                        Image("Left")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .buttonStyle(TriggerButton())
                                Button(action: {
                                    targetDate = DateHelper.nextDay(targetDate)
                                }) {
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
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 16)
                    
                }
                .background {
                    let snapOffset = max(0, min(2, offsetObserver.offset / width))
                    if backgroundTheme == BackgroundTheme.dynamic {
                        if horizontalSizeClass == .compact {
                            ZStack {
                                Group {
                                    switch transformEffect {
                                    case .slide:
                                        Image("Dinner")
                                            .resizable()
                                        Image("Lunch")
                                            .resizable()
                                            .mask(
                                                Rectangle()
                                                    .edgesIgnoringSafeArea(.all)
                                                    .offset(x: width * max(0, min(1, snapOffset - 1)) * -1)
                                            )
                                        Image("Breakfast")
                                            .resizable()
                                            .mask(
                                                Rectangle()
                                                    .edgesIgnoringSafeArea(.all)
                                                    .offset(x: width * max(0, min(1, snapOffset)) * -1)
                                            )
                                    case .fade:
                                        Image("Dinner")
                                            .resizable()
                                        Image("Lunch")
                                            .resizable()
                                            .opacity(Double(max(0, min(1, 2 - snapOffset))))
                                        Image("Breakfast")
                                            .resizable()
                                            .opacity(Double(max(0, min(1, 1 - snapOffset))))
                                    }
                                }
                                .scaledToFill()
                                .frame(width: width, height: height, alignment: .bottom)
                                .ignoresSafeArea()
                            }
                        } else {
                            Image("Dinner")
                                .resizable()
                                .scaledToFill()
                                .frame(width: width, height: height, alignment: .bottom)
                                .ignoresSafeArea()
                        }
                    } else {
                        ZStack {
                            Color("Background")
                                .frame(width: width, height: height)
                                .ignoresSafeArea()
                        }
                    }
                }
            }
            .onChange(of: geometry.size) {
                self.width = geometry.size.width + geometry.safeAreaInsets.leading + geometry.safeAreaInsets.trailing
                self.height = geometry.size.height + geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
            }
            .onChange(of: targetDate) {
                update(targetDate)
            }
            .onAppear() {
                today()
            }
        }
    }
    
    private func today() {
        let current = MealHelper.current(viewContext)
        targetDate = DateHelper.formatToDate(current.date)
        offset = current.target.typeIndex
    }
    
    private func update(_ date: Date) {
        targetDate = date
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

@Observable
class PageOffsetObserver: NSObject {
    var collectionView: UICollectionView?
    var offset: CGFloat = 0
    
    init(offset: CGFloat = 0) {
        self.offset = offset
        super.init()
    }
    
    deinit {
        remove()
    }
    
    private(set) var isObserving: Bool = false
    
    func observe() {
        guard !isObserving else { return }
        collectionView?.addObserver(self, forKeyPath: "contentOffset", context: nil)
        isObserving = true
    }
    
    func remove() {
        isObserving = false
        collectionView?.removeObserver(self, forKeyPath: "contentOffset")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" else { return }
        if let contentOffset = (object as? UICollectionView)?.contentOffset {
            offset = contentOffset.x
        }
    }
}

struct FindCollectionView: UIViewRepresentable {
    var result: (UICollectionView) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if let collectionView = view.collectionSuperView {
                result(collectionView)
            }
        }
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        
    }
}

extension UIView {
    var collectionSuperView: UICollectionView? {
        if let collectionView = superview as? UICollectionView {
            return collectionView
        }
        
        return superview?.collectionSuperView
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
            .navigationViewStyle(.stack)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .preferredColorScheme(scheme)
        }
    }
}
