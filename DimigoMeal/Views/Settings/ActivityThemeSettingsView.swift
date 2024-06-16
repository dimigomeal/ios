//
//  ActivityThemeSettingsView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-15.
//

import SwiftUI

struct ActivityThemeSettingsView: View {
    @AppStorage("theme/activity") private var activityTheme = WidgetTheme.dynamic
    
    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("‘다이나믹’은 앱의 라이브 액티비티의 배경으로 시간에 따른 그라데이션을 제공합니다.\n\n‘시스템 설정’은 기기 설정에 따라 화면 모드를 자동으로 전환합니다.\n\n‘라이트 모드’는 변하지 않는 라이트 화면 모드를 제공합니다.\n\n'다크 모드'는 어두운 화면 모드를 제공하여 라이브 액티비티에서 제공하는 정보가 쉽게 눈에 띄도록 합니다.")) {
                    Picker(selection: $activityTheme, label: Text("액티비티 테마")) {
                        ForEach(WidgetTheme.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            .navigationBarTitle("라이브 액티비티 테마")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
