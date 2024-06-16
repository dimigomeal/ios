//
//  BackgroundThemeSettingsView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-15.
//

import SwiftUI

struct BackgroundThemeSettingsView: View {
    @AppStorage("theme/background") private var backgroundTheme = BackgroundTheme.dynamic
    
    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("‘다이나믹’은 앱의 배경으로 세련된 일러스트를 제공합니다.\n\n‘솔리드’를 선택하면 색상 테마에 맞는 단색 배경을 제공하며 정보에 집중할 때 효과적입니다.\n\n이 설정은 기기에 저장되며, 클라우드에 공유되지 않습니다.")) {
                    Picker(selection: $backgroundTheme, label: Text("배경 테마")) {
                        ForEach(BackgroundTheme.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
            }
            .navigationBarTitle("앱 배경 테마")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
