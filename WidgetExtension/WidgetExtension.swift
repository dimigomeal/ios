//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by noViceMin on 2024-06-16.
//

import WidgetKit
import SwiftUI

private func themeSwitch(_ theme: WidgetConfigurationTheme) -> WidgetTheme {
    switch theme {
    case .light:
        return .light
    case .dark:
        return .dark
    default:
        return .dynamic
    }
}

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> WidgetExtensionEntry {
        WidgetExtensionEntry(
            date: Date(),
            theme: .dynamic,
            data: WidgetData(type: .dinner, menu: dummyMeal.dinner, date: dummyMeal.date)
        )
    }

    func getSnapshot(
        for configuration: WidgetConfigurationIntent,
        in context: Context,
        completion: @escaping (WidgetExtensionEntry) -> ()
    ) {
        let data = getData()
        let entry = WidgetExtensionEntry(
            date: Date(),
            theme: themeSwitch(configuration.theme),
            data: data
        )
        
        print(configuration.theme)
        
        completion(entry)
    }

    func getTimeline(
        for configuration: WidgetConfigurationIntent,
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {
        let currentDate = Date()
        let data = getData()
        let entry = WidgetExtensionEntry(
            date: Date(),
            theme: themeSwitch(configuration.theme),
            data: data
        )
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        
        print(configuration.theme)
        
        completion(timeline)
    }
    
    private func getData() -> WidgetData {
        let viewContext = PersistenceController.shared.container.viewContext

        let meal = MealHelper.current(viewContext)
        return WidgetData(
            type: meal.type,
            menu: meal.menu,
            date: meal.date
        )
    }
}

struct WidgetData {
    let type: MealType
    let menu: String?
    let date: String
}

struct WidgetExtensionEntry: TimelineEntry {
    let date: Date
    let theme: WidgetTheme
    let data: WidgetData
}

struct WidgetExtensionEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        WidgetView(
            theme: entry.theme,
            type: entry.data.type,
            menu: entry.data.menu,
            date: entry.data.date
        )
    }
}

struct WidgetExtension: Widget {
    let kind: String = "WidgetExtension"

    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: WidgetConfigurationIntent.self,
            provider: Provider()
        ) { entry in
            WidgetExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies([.systemMedium])
        .configurationDisplayName("현재 급식")
        .description("현재 급식을 보여줍니다.")
    }
}

#Preview(as: .systemMedium) {
    WidgetExtension()
} timeline: {
    WidgetExtensionEntry(
        date: .now,
        theme: .dynamic,
        data: WidgetData(type: .dinner, menu: dummyMeal.dinner, date: dummyMeal.date)
    )
}
