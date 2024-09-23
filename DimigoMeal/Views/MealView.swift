//
//  MealView.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-13.
//

import SwiftUI

struct MealView: View {
    let type: MealType
    let menu: String?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        Image(type == .breakfast ? "BreakfastIcon" : type == .lunch ? "LunchIcon" : "DinnerIcon")
                            .resizable()
                            .frame(width: 32, height: 32)
                        Text(StringHelper.getTypeString(type))
                            .foregroundColor(Color("Color"))
                            .font(.custom("SUIT-Bold", size: 32))
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(StringHelper.getMealArray(menu), id: \.self) { item in
                            HStack {
                                Text("•")
                                    .foregroundColor(Color("Color"))
                                    .font(.custom("SUIT-Medium", size: 20))
                                Text(item)
                                    .foregroundColor(Color("Color"))
                                    .font(.custom("SUIT-Medium", size: 20))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(17)
            }
            .padding(3)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .background(BackdropBlurView(radius: 48))
        }
        .padding(.horizontal, 16)
    }
}

