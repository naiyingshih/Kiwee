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
    let date = DateFormatterManager.shared.dateFormatter
    
    // MARK: - Post
    
    func postWaterCount(waterCount: Int, chosenDate: Date, completion: @escaping (Bool) -> Void) {

        let dateString = date.string(from: chosenDate)
        
        database.collection("intake")
            .whereField("date", isEqualTo: dateString)
            .whereField("type", isEqualTo: "water")
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching water documents: \(error.localizedDescription)")
                    completion(false)
                } else if let documents = querySnapshot?.documents, !documents.isEmpty {
                    // Document for the current day exists, update it
                    let documentID = documents.first!.documentID
                    self.database.collection("intake").document(documentID).updateData([
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
                        "date": dateString,
                        "type": "water"
                    ]
                    
                    self.database.collection("intake").addDocument(data: waterDictionary) { error in
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
    
    func postIntakeData(intakeData: Food, chosenDate: Date, completion: @escaping (Bool) -> Void) {
       
        let dateString = date.string(from: chosenDate)
        
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
            "date": dateString,
            "type": "food"
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
    
    // MARK: - Get
    
    func getIntakeCard(collectionID: String, chosenDate: Date, completion: @escaping ([Food], Int) -> Void) {
        
        let dateString = date.string(from: chosenDate)
        
        database.collection(collectionID)
            .whereField("date", isEqualTo: dateString)
            .addSnapshotListener { querySnapshot, err in
                if let error = err {
                    print(error)
                    completion([], 0)
                    return
                } else {
                    let foods = self.getIntake(from: querySnapshot?.documents ?? [])
                    let water = self.getWaterQuantity(from: querySnapshot?.documents ?? [])
                    completion(foods, water)
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
                     section: document["section"] as? Int
                    )
            )
        }
        return foodsForToday
    }
    
    private func getWaterQuantity(from documents: [QueryDocumentSnapshot]) -> Int {
        let waterQuantities = documents.compactMap { $0["water_count"] as? Int }
        return waterQuantities.first ?? 0
    }
    
    func fetchAndAggregateData(forLastDays days: Int, completion: @escaping ([Food], Int) -> Void) {
        let dates = generateDateRange(from: days)
        var aggregatedFoods: [Food] = []
        var totalWaterIntake: Int = 0
        
        let dispatchGroup = DispatchGroup()
        
        for date in dates {
            dispatchGroup.enter()
            getIntakeCard(collectionID: "intake", chosenDate: date) { (foods, water) in
                aggregatedFoods.append(contentsOf: foods)
                totalWaterIntake += water
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(aggregatedFoods, totalWaterIntake)
        }
    }
    
    private func generateDateRange(from daysAgo: Int) -> [Date] {
        var dates: [Date] = []
        for dayOffset in (0..<daysAgo).reversed() {
            if let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) {
                dates.append(date)
            }
        }
        return dates
    }
    
    func getOrderedDateData(completion: @escaping ([CalorieDataPoint]) -> Void) {
        database.collection("intake")
            .order(by: "date")
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                } else {
                    var dataPoints: [CalorieDataPoint] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let date = data["date"] as? String,
                           let calories = data["totalCalories"] as? Double {
                            let dataPoint = CalorieDataPoint(date: date, calories: calories)
                            dataPoints.append(dataPoint)
                        }
                    }
                    completion(dataPoints)
                }
            }
    }
    
}
