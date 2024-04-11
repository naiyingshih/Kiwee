//
//  FoodModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import Foundation

struct Food {
    let name: String
    let totalCalorie: Double
    let nutrients: Nutrient
    let image: String
}

struct Nutrient {
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let fiber: Double
}

struct IntakeData {
    let name: String
    let totalCalorie: Double
    let nutrients: Nutrient
    let image: String
    let quantity: Double
}
