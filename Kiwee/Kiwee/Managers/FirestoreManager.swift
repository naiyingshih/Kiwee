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
    
//    func get(collectionID: String, completion: @escaping ([Food]) -> Void) {
//        database.collection("foods").addSnapshotListener { querySnapshot, err in
//            if let error = err {
//                print(error)
//                completion([])
//            } else {
//                completion(self.getFood(from: querySnapshot?.documents ?? []))
//            }
//        }
//    }
//    
//    private func getFood(from documents: [QueryDocumentSnapshot]) -> [Food] {
//        var food = [Food]()
//        for document in documents {
//            let foodData = document["nutrients"] as? [String: Any] ?? [:]
//            let nutrientInfo = Nutrient(
//                carbohydrates: foodData["carbohydrates"] as? Double ?? 0.0,
//                protein: foodData["protein"] as? Double ?? 0.0,
//                fat: foodData["fat"] as? Double ?? 0.0,
//                fiber: foodData["fiber"] as? Double ?? 0.0
//            )
//            food.append(
//                Food(name: document["name"] as? String ?? "",
//                     category: document["category"] as? String ?? "",
//                     totalCalorie: document["totalCalories"] as? Double ?? 0.0,
//                     nutrients: nutrientInfo,
//                     image: document["image"] as? String ?? "")
//            )
//        }
//        return food
//    }
    
    func searchFood(searchText: String, completion: @escaping ([Food]) -> Void) {
        let query = database.collection("foods").whereField("name", isEqualTo: searchText)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error searching for food: \(error.localizedDescription)")
                completion([])
            } else {
                var filteredFoodResults = [Food]()
                for document in querySnapshot!.documents {
                    let foodData = document["nutrients"] as? [String: Any] ?? [:]
                    let nutrientInfo = Nutrient(
                        carbohydrates: foodData["carbohydrates"] as? Double ?? 0.0,
                        protein: foodData["protein"] as? Double ?? 0.0,
                        fat: foodData["fat"] as? Double ?? 0.0,
                        fiber: foodData["fiber"] as? Double ?? 0.0
                    )
                    let food = Food(
                        name: document["name"] as? String ?? "",
                        totalCalorie: document["totalCalories"] as? Double ?? 0.0,
                        nutrients: nutrientInfo,
                        image: document["image"] as? String ?? ""
                    )
                    filteredFoodResults.append(food)
                }
                completion(filteredFoodResults)
            }
        }
    }
    
    func postIntakeData(intakeData: IntakeData, completion: @escaping (Bool) -> Void) {
        let intakeDictionary: [String: Any] = [
            "name": intakeData.name,
            "totalCalorie": intakeData.totalCalorie,
            "nutrients": [
                "carbohydrates": intakeData.nutrients.carbohydrates,
                "protein": intakeData.nutrients.protein,
                "fat": intakeData.nutrients.fat,
                "fiber": intakeData.nutrients.fiber
            ],
            "image": intakeData.image,
            "quantity": intakeData.quantity
        ]
        
        database.collection("intake").addDocument(data: intakeDictionary) { error in
            if let error = error {
                print("Error adding intake data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Intake data added successfully")
                completion(true)
            }
        }
    }

}
