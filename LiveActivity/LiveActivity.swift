//
//  LiveActivity.swift
//  LiveActivity
//
//  Created by noViceMin on 2024-06-13.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LiveActivityAttributes.self) { context in
            WidgetView(
                theme: context.attributes.theme,
                type: context.state.type,
                menu: context.state.menu,
                date: context.state.date
            )
            .activityBackgroundTint(
                MatchBackground(context.attributes.theme, context.state.type)
            )
            .activitySystemActionForegroundColor(
                matchColor(context.attributes.theme, Color("ColorDynamic"), Color("ColorLight"), Color("ColorDark"))
            )

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

extension LiveActivityAttributes {
    fileprivate static var preview: LiveActivityAttributes {
        LiveActivityAttributes(theme: .dynamic)
    }
}

extension LiveActivityAttributes.ContentState {
    fileprivate static var breakfast: LiveActivityAttributes.ContentState {
        LiveActivityAttributes.ContentState(type: .breakfast, menu: dummyMeal.breakfast, date: dummyMeal.date)
    }
    
    fileprivate static var lunch: LiveActivityAttributes.ContentState {
        LiveActivityAttributes.ContentState(type: .lunch, menu: dummyMeal.lunch, date: dummyMeal.date)
    }
    
    fileprivate static var dinner: LiveActivityAttributes.ContentState {
        LiveActivityAttributes.ContentState(type: .dinner, menu: dummyMeal.dinner, date: dummyMeal.date)
    }
}

#Preview("LiveActivity", as: .content, using: LiveActivityAttributes.preview) {
    LiveActivity()
} contentStates: {
    LiveActivityAttributes.ContentState.breakfast
    LiveActivityAttributes.ContentState.lunch
    LiveActivityAttributes.ContentState.dinner
}
