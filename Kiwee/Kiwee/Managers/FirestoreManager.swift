//
//  FirebaseManager.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirestoreManager {
    static let shared = FirestoreManager()
    let database = Firestore.firestore()
    
    func get(collectionID: String, completion: @escaping ([Food]) -> Void) {
        database.collection("foods").addSnapshotListener { querySnapshot, err in
            if let error = err {
                print(error)
                completion([])
            } else {
                completion(FirestoreManager.getFood(from: querySnapshot?.documents ?? []))
            }
        }
    }
    
    static func getFood(from documents: [QueryDocumentSnapshot]) -> [Food] {
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
                     category: document["category"] as? String ?? "",
                     totalCalorie: document["totalCalories"] as? Double ?? 0.0,
                     nutrients: nutrientInfo,
                     image: document["image"] as? String ?? "")
            )
        }
        return food
    }
    
}
