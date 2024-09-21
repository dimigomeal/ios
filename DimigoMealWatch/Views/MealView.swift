//
//  MealView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-13.
//

import SwiftUI

struct MealView: View {
    let date: Date
    let type: MealType
    let menu: String?
    
    @Binding var dateSheet: Bool
    @Binding var todayTrigger: Bool
    
    var body: some View {
        NavigationStack{
            List {
                ForEach(StringHelper.getMealArray(menu), id: \.self) { item in
                    Text(item)
                }
            }
            .listStyle(CarouselListStyle())
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        todayTrigger.toggle()
                    }) {
                        Text(StringHelper.getTypeString(type))
                            .font(.title2)
                    }
                    .buttonStyle(.plain)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dateSheet.toggle()
                    }) {
                        Text(DateHelper.formatShortString(date))
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
