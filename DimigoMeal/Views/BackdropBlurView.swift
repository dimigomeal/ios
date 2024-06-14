//
//  BackdropBlurView.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-13.
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
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.05), radius: 14, x: 0, y: 0)
    }
}
