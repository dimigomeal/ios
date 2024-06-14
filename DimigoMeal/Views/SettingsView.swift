//
//  SettingsView.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI
import ActivityKit


struct SettingsView: View {
    @State private var isLoadingLiveActivity = false
    @State private var isErrorLiveActivity = false
    
    @AppStorage("theme/color") private var colorTheme = ColorTheme.system
    @AppStorage("theme/background") private var backgroundTheme = BackgroundTheme.dynamic
    @AppStorage("theme/activity") private var activityTheme = ActivityTheme.dynamic
    @AppStorage("effect/transform") private var transformEffect = TransformEffect.slide
    @AppStorage("effect/haptic") private var hapticFeedback = true
    @AppStorage("function/liveactivity") private var liveActivity = false
    
    func checkLiveActivity() {
        for activity in Activity<LiveActivityAttributes>.activities {
            print(activity)
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
                Section(header: Text("앱 설정")) {
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
                    NavigationLink(destination: TransformEffectSettingsView()) {
                        HStack {
                            Text("급식 전환 효과")
                            Spacer()
                            Text(transformEffect.rawValue)
                                .foregroundColor(.gray)
                        }
                    }
                    Toggle(isOn: $hapticFeedback) {
                        HStack {
                            Text("햅틱 피드백")
                        }
                    }
                }
                Section(header: Text("라이브 액티비티 설정")) {
                    NavigationLink(destination: ActivityThemeSettingsView()) {
                        HStack {
                            Text("테마")
                            Spacer()
                            Text(activityTheme.rawValue)
                                .foregroundColor(.gray)
                        }
                    }
                    Button(action: {
                        isLoadingLiveActivity = true
                        Task {
                            if liveActivity {
                                await LiveActivityHelper.end()
                            } else {
                                isErrorLiveActivity = !(await LiveActivityHelper.start())
                            }
                            isLoadingLiveActivity = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            if isLoadingLiveActivity {
                                ProgressView()
                            } else {
                                Image(systemName: liveActivity ? "stop.circle" : "play.circle")
                                    .foregroundColor(liveActivity ? .red : .accentColor)
                                Text(liveActivity ? "비활성화" : "활성화")
                                    .foregroundColor(liveActivity ? .red : .accentColor)
                            }
                            Spacer()
                        }
                    }
                    .disabled(isLoadingLiveActivity)
                    .alert(isPresented: $isErrorLiveActivity) {
                        Alert(
                            title: Text("라이브 액티비티 활성화 실패"),
                            message: Text("서버와의 통신 중 오류가 발생했습니다. 다시 시도해주세요."),
                            dismissButton: .default(Text("확인"))
                        )
                    }
                }
                Section(header: Text("초기화")) {
                    Button(action: {
                        colorTheme = .system
                        backgroundTheme = .dynamic
                        activityTheme = .dynamic
                        transformEffect = .slide
                        hapticFeedback = true
                    }) {
                        HStack {
                            Spacer()
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundColor(.red)
                            Text("설정 기본값으로 초기화")
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
                    // "소스코드" with github icon
                    Button(action: {
                        UIApplication.shared.open(URL(string: "https://github.com/dimigomeal")!)
                    }) {
                        HStack {
                            Text("소스코드")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                Section {
                    Image("Senko")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 96)
                        .edgesIgnoringSafeArea(.all)
                    
                }
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowBackground(Color.clear)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .navigationBarTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .edgesIgnoringSafeArea(.bottom)
            .contentMargins(.bottom, 0)
            .onChange(of: activityTheme) {
                Task {
                    await LiveActivityHelper.reload()
                }
            }
        }
    }
    
    func appVersion() -> String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        } else {
            return ""
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
            .navigationBarTitle("앱 색상 테마")
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
            .navigationBarTitle("앱 배경 테마")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

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

struct ActivityThemeSettingsView: View {
    @AppStorage("theme/activity") private var activityTheme = ActivityTheme.dynamic
    
    var body: some View {
        NavigationStack {
            List {
                Section(footer: Text("‘다이나믹’은 앱의 라이브 액티비티의 배경으로 시간에 따른 그라데이션을 제공합니다.\n\n‘시스템 설정’은 기기 설정에 따라 화면 모드를 자동으로 전환합니다.\n\n‘라이트 모드’는 변하지 않는 라이트 화면 모드를 제공합니다.\n\n'다크 모드'는 어두운 화면 모드를 제공하여 라이브 액티비티에서 제공하는 정보가 쉽게 눈에 띄도록 합니다.")) {
                    Picker(selection: $activityTheme, label: Text("액티비티 테마")) {
                        ForEach(ActivityTheme.allCases, id: \.self) {
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
