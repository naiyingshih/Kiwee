//
//  FoodModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import Foundation

struct Food: Codable {
    let documentID: String?
    let name: String
    var totalCalories: Double
    var nutrients: Nutrient
    let image: String
    var quantity: Double?
    let section: Int?
    let date: Date?
}

struct Nutrient: Codable {
    var carbohydrates: Double
    var protein: Double
    var fat: Double
    var fiber: Double
}

extension Food {
    func generateIdentifier() -> String {
        return "\(name)-\(totalCalories)-\(nutrients.carbohydrates)-\(nutrients.protein)-\(nutrients.fat)-\(nutrients.fiber)".hashValue.description
    }
}
