//
//  ThemeModel.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-13.
//

import SwiftUI

enum ColorTheme: String, CaseIterable {
    case system = "시스템 설정"
    case light = "라이트 모드"
    case dark = "다크 모드"
    
    var scheme: ColorScheme? {
        switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
        }
    }
}

enum BackgroundTheme: String, CaseIterable {
    case dynamic = "다이나믹"
    case solid = "솔리드"
}

enum ActivityTheme: String, CaseIterable, Codable {
    case dynamic = "다이나믹"
    case light = "라이트 모드"
    case dark = "다크 모드"
    
    var scheme: ColorScheme {
        switch self {
            case .light: return .light
            case .dark: return .dark
            case .dynamic: return .dark
        }
    }
}

func matchColor(_ theme: ActivityTheme, _ dynamic: Color, _ light: Color, _ dark: Color) -> Color {
    switch theme {
        case .dynamic: return dynamic
        case .light: return light
        case .dark: return dark
    }
}
