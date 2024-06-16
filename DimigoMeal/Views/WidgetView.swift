//
//  WidgetView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-16.
//

import ActivityKit
import WidgetKit
import SwiftUI

func MatchColor(_ theme: WidgetTheme) -> Color {
    switch theme {
    case .dynamic:
        return Color("ColorDynamic")
    case .light:
        return Color("ColorLight")
    case .dark:
        return Color("ColorDark")
    }
}

func MatchBackground(_ theme: WidgetTheme, _ type: MealType) -> Color {
    switch theme {
    case .dynamic:
        switch type {
        case .breakfast:
            return Color("DynamicBreakfastEnd")
        case .lunch:
            return Color("DynamicLunchEnd")
        case .dinner:
            return Color("DynamicDinnerEnd")
        }
    case .light:
        return Color("BackgroundLight")
    case .dark:
        return Color("BackgroundDark")
    }
}

func MatchGradientBackground(_ theme: WidgetTheme, _ type: MealType) -> LinearGradient {
    switch theme {
    case .dynamic:
        var startColor = Color.clear
        var endColor = Color.clear
        switch type {
        case .breakfast:
            startColor = Color("DynamicBreakfastStart")
            endColor = Color("DynamicBreakfastEnd")
        case .lunch:
            startColor = Color("DynamicLunchStart")
            endColor = Color("DynamicLunchEnd")
        case .dinner:
            startColor = Color("DynamicDinnerStart")
            endColor = Color("DynamicDinnerEnd")
        }
        
        return LinearGradient(colors: [startColor, endColor], startPoint: .topLeading, endPoint: .bottomTrailing)
    case .light:
        return LinearGradient(colors: [Color("BackgroundLight")], startPoint: .center, endPoint: .center)
    case .dark:
        return LinearGradient(colors: [Color("BackgroundDark")], startPoint: .center, endPoint: .center)
    }
}
/*
binding: theme, type, menu, date
 VStack(spacing: 16) {
     HStack {
         Image(type == .breakfast ? "BreakfastIcon" : type == .lunch ? "LunchIcon" : "DinnerIcon")
             .resizable()
             .frame(width: 20, height: 20)
         Text(type == .breakfast ? "아침" : type == .lunch ? "점심" : "저녁")
             .foregroundColor(MatchColor(context.attributes.theme))
             .font(.custom("SUIT-Bold", size: 20))
         Spacer()
         Text(DateHelper.formatToStringFormat(date))
             .foregroundColor(MatchColor(theme))
             .font(.custom("SUIT-Medium", size: 14))
             .opacity(0.7)
     }
     WrappingHStack(horizontalSpacing: 6, verticalSpacing: 6) {
         ForEach("\(menu ?? "급식 정보가 없습니다")".components(separatedBy: "/"), id: \.self) { item in
             VStack {
                 Text(item)
                     .foregroundColor(MatchColor(context.attributes.theme))
                     .font(.custom("SUIT-Medium", size: 12))
             }
             .padding(.horizontal, 6)
             .frame(minHeight: 24)
             .background(context.attributes.theme == .dynamic ? Color("ColorDynamic").opacity(0.12) : Color("ItemBackground"))
             .cornerRadius(6)
         }
     }
 }
 .frame(maxHeight: .infinity, alignment: .topLeading)
 .padding(16)
 */
// make WidgetView
struct WidgetView: View {
    var theme: WidgetTheme
    var type: MealType
    var menu: String?
    var date: String
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(type == .breakfast ? "BreakfastIcon" : type == .lunch ? "LunchIcon" : "DinnerIcon")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(type == .breakfast ? "아침" : type == .lunch ? "점심" : "저녁")
                    .foregroundColor(MatchColor(theme))
                    .font(.custom("SUIT-Bold", size: 20))
                Spacer()
                Text(DateHelper.formatToStringFormat(date))
                    .foregroundColor(MatchColor(theme))
                    .font(.custom("SUIT-Medium", size: 14))
                    .opacity(0.7)
            }
            WrappingHStack(horizontalSpacing: 6, verticalSpacing: 6) {
                ForEach("\(menu ?? "급식 정보가 없습니다")".components(separatedBy: "/"), id: \.self) { item in
                    VStack {
                        Text(item)
                            .foregroundColor(MatchColor(theme))
                            .font(.custom("SUIT-Medium", size: 12))
                    }
                    .padding(.horizontal, 6)
                    .frame(minHeight: 24)
                    .background(theme == .dynamic ? Color("ColorDynamic").opacity(0.12) : Color("ItemBackground"))
                    .cornerRadius(6)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            MatchGradientBackground(theme, type)
        )
        .colorScheme(theme.scheme)
    }
}
