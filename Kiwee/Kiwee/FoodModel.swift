//
//  FoodModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import Foundation
import Firebase
import FirebaseFirestore

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

extension Food {
    static func build(from documents: [QueryDocumentSnapshot]) -> [Food] {
        var food = [Food]()
        for document in documents {
            let foodData = document["nutrients"] as? [String: Any] ?? [:]
            let nutrientInfo = Nutrient(
                carbohydrates: foodData["carbohydrates"] as? Double ?? 0.0,
                protein: foodData["protein"] as? Double ?? 0.0,
                fat: foodData["fat"] as? Double ?? 0.0,
                fiber: foodData["fiber"] as? Double ?? 0.0
            )
            food.append(
                Food(name: document["name"] as? String ?? "",
                     totalCalorie: document["totalCalories"] as? Double ?? 0.0,
                     nutrients: nutrientInfo,
                     image: document["image"] as? String ?? "")
            )
        }
        return food
    }
}
