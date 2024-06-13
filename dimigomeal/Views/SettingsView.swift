//
//  SettingsView.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI


struct SettingsView: View {
    @AppStorage("theme/color") private var colorTheme = ColorTheme.system
    @AppStorage("theme/background") private var backgroundTheme = BackgroundTheme.dynamic
    
    func appVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return ""
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack {
                        Image("Icon")
                            .resizable()
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        Text("디미고 급식")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.clear)
                Section(header: Text("테마 설정")) {
                    NavigationLink(destination: ColorThemeSettingsView()) {
                        HStack {
                            Text("색상 테마")
                            Spacer()
                            Text(colorTheme.rawValue)
                                .foregroundColor(.gray)
                        }
                    }
                    NavigationLink(destination: BackgroundThemeSettingsView()) {
                        HStack {
                            Text("배경 테마")
                            Spacer()
                            Text(backgroundTheme.rawValue)
                                .foregroundColor(.gray)
                        }
                    }
                    Button(action: {
                        colorTheme = .system
                        backgroundTheme = .dynamic
                    }) {
                        HStack {
                            Spacer()
                            Text("기본값으로 초기화")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
                Section(header: Text("앱 정보")) {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text(appVersion())
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationBarTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

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
            .navigationBarTitle("색상 테마")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

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
            .navigationBarTitle("배경 테마")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    @Previewable @AppStorage("theme/color") var colorTheme = ColorTheme.system
    
    NavigationView {
        SettingsView()
    }
    .preferredColorScheme(colorTheme.scheme)
}
 
