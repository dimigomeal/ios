//
//  ColorThemeSettingsView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-15.
//

import SwiftUI

struct ColorThemeSettingsView: View {
    @AppStorage("theme/color") private var colorTheme = ColorTheme.system
    
    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("시스템 설정은 기기 설정에 따라 화면 모드를 자동으로 전환합니다.\n\n라이트 모드는 변하지 않는 라이트 화면 모드를 제공합니다.\n\n다크 모드를 선택하면 어두운 화면 모드를 제공하여 앱에서 제공하는 정보가 쉽게 눈에 띄도록 합니다.")) {
                    Picker(selection: $colorTheme, label: Text("색상 테마")) {
                        ForEach(ColorTheme.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                }
            }
            .navigationBarTitle("앱 색상 테마")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
