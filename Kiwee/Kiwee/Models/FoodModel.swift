//
//  FoodModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import Foundation

struct Food: Codable {
    let name: String
    let totalCalories: Double
    let nutrients: Nutrient
    let image: String
    let quantity: Double?
    let section: Int?
//    let date: Date?
}

struct Nutrient: Codable {
    let carbohydrates: Double
    let protein: Double
    let fat: Double
    let fiber: Double
}
