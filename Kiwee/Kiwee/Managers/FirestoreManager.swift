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
    
    func postWaterCount(waterCount: Int, completion: @escaping (Bool) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        database.collection("water")
            .whereField("created_time", isGreaterThanOrEqualTo: startOfDay)
            .whereField("created_time", isLessThan: endOfDay)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching water documents: \(error.localizedDescription)")
                    completion(false)
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    // Document for the current day exists, update it
                    let documentID = documents.first!.documentID
                    self.database.collection("water").document(documentID).updateData([
                        "water_count": waterCount
                    ]) { error in
                        if let error = error {
                            print("Error updating water count: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Water count updated successfully")
                            completion(true)
                        }
                    }
                } else {
                    // No document for the current day, create a new one
                    let waterDictionary: [String: Any] = [
                        "water_count": waterCount,
                        "created_time": FieldValue.serverTimestamp()
                    ]
                    
                    self.database.collection("water").addDocument(data: waterDictionary) { error in
                        if let error = error {
                            print("Error adding water intake: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Water intake data added successfully")
                            completion(true)
                        }
                    }
                }
            }
    }
    
//    func postWaterCount(waterCount: Int, completion: @escaping (Bool) -> Void) {
//        let waterDictionary: [String: Any] = [
//            "water_count": waterCount,
//            "created_time": FieldValue.serverTimestamp()
//        ]
//        
//        database.collection("water").addDocument(data: waterDictionary) { error in
//            if let error = error {
//                print("Error adding water intake: \(error.localizedDescription)")
//                completion(false)
//            } else {
//                print("Water intake data added successfully")
//                completion(true)
//            }
//        }
//    }
    
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
                print("Food intake data added successfully")
                completion(true)
            }
        }
    }
    
    func getIntakeCard(startOfDay: Date, endOfDay: Date, completion: @escaping ([Food], Int) -> Void) {
        let foodCollection = database.collection("intake")
        let waterCollection = database.collection("water")
        
        foodCollection
            .whereField("created_time", isGreaterThanOrEqualTo: startOfDay)
            .whereField("created_time", isLessThan: endOfDay)
            .getDocuments { (foodSnapshot, foodError) in
                guard let foodDocuments = foodSnapshot?.documents, foodError == nil else {
                    print("Error fetching food documents: \(foodError!.localizedDescription)")
                    completion([], 0)
                    return
                }
                let foods = self.getIntake(from: foodDocuments)
                
                waterCollection
                    .whereField("created_time", isGreaterThanOrEqualTo: startOfDay)
                    .whereField("created_time", isLessThan: endOfDay)
                    .getDocuments { (waterSnapshot, waterError) in
                        guard let waterDocuments = waterSnapshot?.documents, waterError == nil else {
                            print("Error fetching water documents: \(waterError!.localizedDescription)")
                            completion([], 0)
                            return
                        }
                        let waterQuantity = self.getWaterQuantity(from: waterDocuments)
                        
                        completion(foods, waterQuantity)
                    }
            }
    }
    
//    func getIntakeCard(collectionID: String, startOfDay: Date, endOfDay: Date, completion: @escaping ([Food], Int) -> Void) {
//        let foodCollection = database.collection("foods")
//        let waterCollection = database.collection("waterIntake")
//        
//        foodCollection.whereField("created_time", isGreaterThanOrEqualTo: startOfDay)
//            .whereField("created_time", isLessThan: endOfDay)
//            .addSnapshotListener { querySnapshot, err in
//                if let error = err {
//                    print(error)
//                    completion([], 0)
//                    return
//                } else {
//                    let foods = self.getIntake(from: querySnapshot?.documents ?? [])
//                    let water = self.getWaterQuantity(from: querySnapshot?.documents ?? [])
//                    completion(foods, water)
//                }
//            }
//    }

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
                     section: document["section"] as? Int
                    )
            )
        }
        return foodsForToday
    }
    
    private func getWaterQuantity(from documents: [QueryDocumentSnapshot]) -> Int {
//        var waterQuantityForToday = Int()
//        for document in documents {
//            let waterData = document["water_count"] as? Int ?? 0
//            waterQuantityForToday = waterData
//        }
        let waterQuantities = documents.compactMap { $0["water_count"] as? Int }
        return waterQuantities.first ?? 0
    }
    
}
