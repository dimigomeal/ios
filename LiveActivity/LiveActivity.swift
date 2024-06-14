//
//  LiveActivity.swift
//  LiveActivity
//
//  Created by noViceMin on 2024-06-13.
//

import ActivityKit
import WidgetKit
import SwiftUI

func MatchColor(_ theme: ActivityTheme) -> Color {
    switch theme {
    case .dynamic:
        return Color("ColorDynamic")
    case .light:
        return Color("ColorLight")
    case .dark:
        return Color("ColorDark")
    }
}

func MatchBackground(_ theme: ActivityTheme, _ type: MealType) -> Color {
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

func MatchGradientBackground(_ theme: ActivityTheme, _ type: MealType) -> LinearGradient {
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

struct LiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var type: MealType
        var menu: String?
        var date: String
    }
    
    var theme: ActivityTheme
}

struct LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            VStack(spacing: 16) {
                HStack {
                    Image(context.state.type == .breakfast ? "BreakfastIcon" : context.state.type == .lunch ? "LunchIcon" : "DinnerIcon")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text(context.state.type == .breakfast ? "아침" : context.state.type == .lunch ? "점심" : "저녁")
                        .foregroundColor(MatchColor(context.attributes.theme))
                        .font(.custom("SUIT-Bold", size: 20))
                    Spacer()
                    Text(DateHelper.formatToStringFormat(context.state.date))
                        .foregroundColor(MatchColor(context.attributes.theme))
                        .font(.custom("SUIT-Medium", size: 14))
                        .opacity(0.7)
                }
                WrappingHStack(horizontalSpacing: 6, verticalSpacing: 6) {
                    ForEach("\(context.state.menu ?? "급식 정보가 없습니다")".components(separatedBy: "/"), id: \.self) { item in
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
            .frame(alignment: .topLeading)
            .padding(16)
            .background(
                MatchGradientBackground(context.attributes.theme, context.state.type)
            )
            .activityBackgroundTint(
                MatchBackground(context.attributes.theme, context.state.type)
            )
            .activitySystemActionForegroundColor(
                matchColor(context.attributes.theme, Color("ColorDynamic"), Color("ColorLight"), Color("ColorDark"))
            )
            .colorScheme(context.attributes.theme.scheme)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }
            } compactLeading: {
                Image(context.state.type == .breakfast ? "BreakfastIcon" : context.state.type == .lunch ? "LunchIcon" : "DinnerIcon")
                    .resizable()
                    .frame(width: 20, height: 20)
            } compactTrailing: {
                EmptyView()
            } minimal: {
                Image(context.state.type == .breakfast ? "BreakfastIcon" : context.state.type == .lunch ? "LunchIcon" : "DinnerIcon")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
    }
}

//extension DynamicIslandWidgetAttributes {
//    fileprivate static var preview: DynamicIslandWidgetAttributes {
//        DynamicIslandWidgetAttributes(name: "World")
//    }
//}
//
//extension DynamicIslandWidgetAttributes.ContentState {
//    fileprivate static var smiley: DynamicIslandWidgetAttributes.ContentState {
//        DynamicIslandWidgetAttributes.ContentState(emoji: "😀")
//     }
//     
//     fileprivate static var starEyes: DynamicIslandWidgetAttributes.ContentState {
//         DynamicIslandWidgetAttributes.ContentState(emoji: "🤩")
//     }
//}
//
//#Preview("Notification", as: .content, using: DynamicIslandWidgetAttributes.preview) {
//   DynamicIslandWidgetLiveActivity()
//} contentStates: {
//    DynamicIslandWidgetAttributes.ContentState.smiley
//    DynamicIslandWidgetAttributes.ContentState.starEyes
//}
