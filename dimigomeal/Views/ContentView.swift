//
//  ContentView.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI

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
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(type == .breakfast ? "BreakfastIcon" : type == .lunch ? "LunchIcon" : "DinnerIcon")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text(type == .breakfast ? "아침" : type == .lunch ? "점심" : "저녁")
                            .foregroundColor(Color("Color"))
                            .font(.custom("SUIT-Bold", size: 32))
                        Spacer()
                    }
                }
                .padding(13)
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
        @State var size: CGSize = .zero
        @State private var pressed = false
        @State private var skip = false

        let configuration: PrimitiveButtonStyle.Configuration
        
        var body: some View {
            GeometryReader { proxy in
                return configuration.label
                    .onAppear {
                        size = proxy.size
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(BackdropBlurView(radius: 20))
                    .opacity(pressed ? 0.6 : 1)
                    .shadow(color: Color.black.opacity(pressed ? 0.2 : 0.05), radius: 14, x: 0, y: 0)
                    .scaleEffect(pressed ? 1.02 : 1)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                if value.location.x < 0 || value.location.x > size.width || value.location.y < 0 || value.location.y > size.height {
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
    
    @AppStorage("theme/background") private var backgroundTheme = BackgroundTheme.dynamic
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            Group {
                                Button(action: { }) {
                                    VStack {
                                        Text("6월 12일 수요일")
                                            .foregroundColor(Color("Color"))
                                            .font(.custom("SUIT-Bold", size: 20))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                NavigationLink(destination: SettingsView()) {
                                    VStack {
                                        Image("Menu")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .frame(width: 56)
                            }
                            .buttonStyle(TriggerButton())
                        }
                        .padding(.horizontal, 16)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                MealView(type: .breakfast)
                                MealView(type: .lunch)
                                MealView(type: .dinner)
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
                            Group {
                                Button(action: { }) {
                                    VStack {
                                        Image("Left")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                Button(action: { }) {
                                    VStack {
                                        Image("Right")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
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
        }
    }
}

#Preview {
    @Previewable @AppStorage("theme/color") var colorTheme = ColorTheme.system
    
    NavigationView {
        ContentView()
    }
    .preferredColorScheme(colorTheme.scheme)
}
