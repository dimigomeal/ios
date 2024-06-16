//
//  TransformEffectSettingsView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-15.
//

import SwiftUI

struct TransformEffectSettingsView: View {
    @AppStorage("effect/transform") private var transformEffect = TransformEffect.slide
    
    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("‘슬라이드’는 급식 전환 시 슬라이드 효과를 제공합니다.\n\n‘페이드’는 급식 전환 시 페이드 효과를 제공합니다.")) {
                    Picker(selection: $transformEffect, label: Text("급식 전환 효과")) {
                        ForEach(TransformEffect.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            .navigationBarTitle("급식 전환 효과")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
