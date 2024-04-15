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
    
    func postIntakeData(intakeData: Food, completion: @escaping (Bool) -> Void) {
        let intakeDictionary: [String: Any] = [
            "name": intakeData.name,
            "totalCalories": intakeData.totalCalories,
            "nutrients": [
                "carbohydrates": intakeData.nutrients.carbohydrates,
                "protein": intakeData.nutrients.protein,
                "fat": intakeData.nutrients.fat,
                "fiber": intakeData.nutrients.fiber
            ],
            "image": intakeData.image,
            "quantity": intakeData.quantity as Any,
            "section": intakeData.section as Any,
            "created_time": FieldValue.serverTimestamp()
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
    
//    func getIntakeCard(collectionID: String, completion: @escaping ([Food]) -> Void) {
//        let startOfDay = Calendar.current.startOfDay(for: Date())
//        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
//
//        database.collection("intake")
//            .whereField("created_time", isGreaterThanOrEqualTo: startOfDay)
//            .whereField("created_time", isLessThan: endOfDay)
//            .addSnapshotListener { querySnapshot, err in
//                if let error = err {
//                    print(error)
//                    completion([])
//                } else {
//                    let foods = self.getIntake(from: querySnapshot?.documents ?? [])
//                    completion(foods)
//                }
//            }
//    }
    
    func getIntakeCard(collectionID: String, startOfDay: Date, endOfDay: Date, completion: @escaping ([Food]) -> Void) {
        database.collection(collectionID)
            .whereField("created_time", isGreaterThanOrEqualTo: startOfDay)
            .whereField("created_time", isLessThan: endOfDay)
            .addSnapshotListener { querySnapshot, err in
                if let error = err {
                    print(error)
                    completion([])
                } else {
                    let foods = self.getIntake(from: querySnapshot?.documents ?? [])
                    completion(foods)
                }
            }
    }

    private func getIntake(from documents: [QueryDocumentSnapshot]) -> [Food] {
        var foodsForToday = [Food]()
        for document in documents {
            let foodData = document["nutrients"] as? [String: Any] ?? [:]
            let nutrientInfo = Nutrient(
                carbohydrates: foodData["carbohydrates"] as? Double ?? 0.0,
                protein: foodData["protein"] as? Double ?? 0.0,
                fat: foodData["fat"] as? Double ?? 0.0,
                fiber: foodData["fiber"] as? Double ?? 0.0
            )
            foodsForToday.append(
                Food(name: document["name"] as? String ?? "",
                     totalCalories: document["totalCalories"] as? Double ?? 0.0,
                     nutrients: nutrientInfo,
                     image: document["image"] as? String ?? "",
                     quantity: document["quantity"] as? Double,
                     section: document["section"] as? Int,
                     date: document["created_time"] as? Date ?? Date()
                    )
            )
        }
        return foodsForToday
    }
    
}
