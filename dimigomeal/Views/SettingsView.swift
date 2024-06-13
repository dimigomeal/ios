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
                Picker(selection: $colorTheme, label: Text("색상 테마")) {
                    ForEach(ColorTheme.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .labelsHidden()
                .pickerStyle(.inline)
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
                Picker(selection: $backgroundTheme, label: Text("배경 테마")) {
                    ForEach(BackgroundTheme.allCases, id: \.self) {
                        Text($0.rawValue)
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
 
