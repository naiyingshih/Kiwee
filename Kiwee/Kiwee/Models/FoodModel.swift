//
//  FoodModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import Foundation

//struct Food {
//    let name: String
//    let totalCalorie: Double
//    let nutrients: Nutrient
//    let image: String
//}

struct Food: Codable {
    let name: String
    let totalCalories: Double
    let nutrients: Nutrient
    let image: String
    let quantity: Double?
}

struct IntakeData {
    let name: String
    let totalCalorie: Double
    let nutrients: Nutrient
    let image: String
    let quantity: Double
}

struct Nutrient: Codable {
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let fiber: Double
}
