//
//  TriggerButton.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-13.
//

import SwiftUI

struct TriggerButton: PrimitiveButtonStyle {
    struct MyButton: View {
        @State private var pressed = false
        @State private var skip = false
        
        @AppStorage("effect/haptic") private var hapticFeedback = true

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
                        if hapticFeedback {
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    })
                    .onChange(of: pressed) { _, value in
                        if !value {
                            if hapticFeedback {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                            
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
    
    func makeBody(configuration: PrimitiveButtonStyle.Configuration) -> some View {
        MyButton(configuration: configuration)
    }
}
