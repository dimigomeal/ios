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

func layout(sizes: [CGSize], spacing: CGFloat = 8, containerWidth: CGFloat) -> (offsets: [CGPoint], size: CGSize) {
    var result: [CGPoint] = []
    
    var currentPosition: CGPoint = .zero
    
    var lineHeight: CGFloat = 0
    
    var maxX: CGFloat = 0
    for size in sizes {
        
        if currentPosition.x + size.width > containerWidth {
            currentPosition.x = 0
            currentPosition.y += lineHeight + spacing
            lineHeight = 0
        }
        result.append(currentPosition)
        currentPosition.x += size.width
        
        maxX = max(maxX, currentPosition.x)
        currentPosition.x += spacing
        lineHeight = max(lineHeight, size.height)
    }
    return (result, .init(width: maxX, height: currentPosition.y + lineHeight))
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let containerWidth = proposal.width ?? .infinity
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, spacing: spacing, containerWidth: containerWidth).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets =
        layout(sizes: sizes, spacing: spacing, containerWidth: bounds.width).offsets
        for (offset, subview) in zip(offsets, subviews) {
            subview.place(at: .init(x: offset.x + bounds.minX, y: offset.y + bounds.minY), proposal: .unspecified)
        }
    }
}

struct WidgetView: View {
    var theme: WidgetTheme
    var type: MealType
    var menu: String?
    var date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(type == .breakfast ? "BreakfastIcon" : type == .lunch ? "LunchIcon" : "DinnerIcon")
                    .resizable()
                    .frame(width: 20, height: 20)
                Text(StringHelper.getTypeString(type))
                    .foregroundColor(MatchColor(theme))
                    .font(.custom("SUIT-Bold", size: 20))
                Spacer()
                Text(DateHelper.formatToStringFormat(date))
                    .foregroundColor(MatchColor(theme))
                    .font(.custom("SUIT-Medium", size: 14))
                    .opacity(0.7)
            }
            AnyLayout(FlowLayout(spacing: 6)) {
                ForEach(StringHelper.getMealArray(menu), id: \.self) { item in
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(16)
        .background(
            MatchGradientBackground(theme, type)
        )
        .colorScheme(theme.scheme)
    }
}
