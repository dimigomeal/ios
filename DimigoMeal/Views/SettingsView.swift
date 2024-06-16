//
//  SettingsView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-12.
//

import SwiftUI
import ActivityKit

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isLoadingLiveActivity = false
    @State private var isErrorLiveActivity = false
    
    @AppStorage("theme/color") private var colorTheme = ColorTheme.system
    @AppStorage("theme/background") private var backgroundTheme = BackgroundTheme.dynamic
    @AppStorage("theme/activity") private var activityTheme = WidgetTheme.dynamic
    @AppStorage("effect/transform") private var transformEffect = TransformEffect.slide
    @AppStorage("effect/haptic") private var hapticFeedback = true
    @AppStorage("function/liveactivity") private var liveActivity = false
    @AppStorage("debug/enable") private var debug = false
    @AppStorage("debug/endpoint") private var endpoint = ""
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack {
                        Image("Icon")
                            .resizable()
                            .frame(width: 96, height: 96)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .rotationEffect(.degrees(debug ? 180 : 0))
                            .onLongPressGesture(perform: {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                debug.toggle()
                            })
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
                                isErrorLiveActivity = !(await LiveActivityHelper.start(viewContext))
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
                
                debug ? Group {
                    Section(header: Text("DEBUG / Endpoint")) {
                        TextField("Endpoint", text: $endpoint)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        Button(action: {
                            endpoint = ""
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                Text("RESET")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                } : nil
            }
            .navigationBarTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: activityTheme) {
                Task {
                    await LiveActivityHelper.reload(viewContext)
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
