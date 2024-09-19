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
                    Text(StringHelper.getTypeString(type))
                        .font(.title2)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Text(DateHelper.formatShortString(date))
                        .font(.subheadline)
                }
            }
        }
    }
}
