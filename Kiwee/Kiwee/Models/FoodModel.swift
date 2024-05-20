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
    var type: String? = "food"
    
    struct Nutrient: Codable {
        var carbohydrates: Double
        var protein: Double
        var fat: Double
        var fiber: Double
    }
}

struct WaterCount: Codable {
    var id: String
    var waterCount: Int
    var date: Date
    var type: String = "water"
    var documentID: String
    
    enum CodingKeys: String, CodingKey {
        case id, date, type, documentID
        case waterCount = "water_count"
    }
}

extension Food {
    func generateIdentifier() -> String {
        return "\(name)-\(totalCalories)-\(nutrients.carbohydrates)-\(nutrients.protein)-\(nutrients.fat)-\(nutrients.fiber)".hashValue.description
    }
}
