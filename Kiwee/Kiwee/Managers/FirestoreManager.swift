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

//        let dateString = date.string(from: chosenDate)
        let startOfDay = Calendar.current.startOfDay(for: chosenDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        database.collection("intake")
//            .whereField("date", isEqualTo: chosenDate)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
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
                        "date": chosenDate,
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
       
//        let dateString = date.string(from: chosenDate)
        
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
            "date": Timestamp(date: chosenDate),
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
    
    // TODO: wait to put in launch page
    func postUserData(input: UserData, completion: @escaping (Bool) -> Void) {
        let userDictionary: [String: Any] = [
            "id": "uuid()",
            "name": input.name,
            "gender": input.gender,
            "age": input.age,
            "goal": input.goal,
            "activeness": input.activeness,
            "height": input.height,
            "initial_weight": input.initialWeight,
            "goal_weight": input.goalWeight,
            "achievement_time": input.achievementTime,
            "date": FieldValue.serverTimestamp()
        ]
        
        database.collection("users").addDocument(data: userDictionary) { error in
            if let error = error {
                print("Error adding intake data: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Food intake data added successfully")
                completion(true)
            }
        }
    }
    
    func updatePartialUserData(id: String, updates: [String: Any], completion: @escaping (Bool) -> Void) {
        database.collection("users")
            .whereField("id", isEqualTo: id)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error finding document: \(error.localizedDescription)")
                    completion(false)
                } else if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                    let document = querySnapshot.documents.first
                    document?.reference.updateData(updates) { error in
                        if let error = error {
                            print("Error updating document: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Document successfully updated")
                            completion(true)
                        }
                    }
                } else {
                    print("No document found with the id: \(id)")
                    completion(false)
                }
            }
    }
    
//    func updateUserData(id: String, userInput: UserData, completion: @escaping (Bool) -> Void) {
//        database.collection("users")
//            .whereField("id", isEqualTo: id)
//            .getDocuments { (querySnapshot, err) in
//                if let err = err {
//                    print("Error getting documents: \(err)")
//                    completion(false)
//                } else {
//                    for document in querySnapshot!.documents {
//                        let documentId = document.documentID
//                        let updateDictionary: [String: Any] = [
//                            "height": userInput.height,
//                            "updated_weight": userInput.updatedWeight ?? userInput.initialWeight,
//                            "goal": userInput.goal,
//                            "goal_weight": userInput.goalWeight,
//                            "activeness": userInput.activeness,
//                            "achievement_time": userInput.achievementTime
//                        ]
//                        
//                        self.database.collection("users").document(documentId)
//                            .updateData(updateDictionary) { error in
//                            if let error = error {
//                                print("Error updating document: \(error.localizedDescription)")
//                                completion(false)
//                            } else {
//                                print("Document successfully updated")
//                                completion(true)
//                            }
//                        }
//                    }
//                }
//            }
//    }
    
    // MARK: - Get
    
    func getIntakeCard(collectionID: String, chosenDate: Date, completion: @escaping ([Food], Int) -> Void) {
        
        //        let dateString = date.string(from: chosenDate)
        let startOfDay = Calendar.current.startOfDay(for: chosenDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        database.collection(collectionID)
//            .whereField("date", isEqualTo: chosenDate)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
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
        
//        let dispatchGroup = DispatchGroup()
        
        for date in dates {
//            dispatchGroup.enter()
            getIntakeCard(collectionID: "intake", chosenDate: date) { (foods, water) in
                aggregatedFoods.append(contentsOf: foods)
                totalWaterIntake += water
                completion(aggregatedFoods, totalWaterIntake)
//                dispatchGroup.leave()
            }
        }
        
//        dispatchGroup.notify(queue: .main) {
//            completion(aggregatedFoods, totalWaterIntake)
//        }
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
    
    func getOrderedDateData(completion: @escaping ([DataPoint]) -> Void) {
        database.collection("intake")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                } else {
                    var dataPoints: [DataPoint] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let timestamp = data["date"] as? Timestamp,
                           let calories = data["totalCalories"] as? Double {
                            let date = timestamp.dateValue()
                            let dataPoint = DataPoint(date: date, dataPoint: calories)
                            dataPoints.append(dataPoint)
                        }
                    }
                    completion(dataPoints)
                }
            }
    }
    
    func getUserWeight(completion: @escaping ([DataPoint]) -> Void) {
        database.collection("users").document("Un9y8lW7NM5ghB43ll7r").collection("current_weight")
            .order(by: "date")
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                } else {
                    var dataPoints: [DataPoint] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        if let timestamp = data["date"] as? Timestamp,
                           let weight = data["weight"] as? Double {
                            let date = timestamp.dateValue()
                            let dataPoint = DataPoint(date: date, dataPoint: weight)
                            dataPoints.append(dataPoint)
                        }
                    }
                    completion(dataPoints)
                }
            }
    }
    
    func getUserData(completion: @escaping (UserData) -> Void) {
        database.collection("users")
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let id = "Un9y8lW7NM5ghB43ll7r"
                        let name = data["name"] as? String ?? ""
                        let gender = data["gender"] as? String ?? ""
                        let age = data["age"] as? Int ?? 0
                        let goal = data["goal"] as? Int ?? 0
                        let activeness = data["activeness"] as? Int ?? 0
                        let currentHeight = data["height"] as? Double ?? 0.0
                        let currentWeight = data["initial_weight"] as? Double ?? 0.0
                        let updatedWeight = data["updated_weight"] as? Double ?? currentWeight
                        let goalWeight = data["goal_weight"] as? Double ?? 0.0
                        let achievementTime = (data["achievement_time"] as? Timestamp)?.dateValue() ?? Date()
                        
                        let userData = UserData(
                            id: id,
                            name: name,
                            gender: gender,
                            age: age,
                            goal: goal,
                            activeness: activeness,
                            height: currentHeight,
                            initialWeight: currentWeight, 
                            updatedWeight: updatedWeight,
                            goalWeight: goalWeight,
                            achievementTime: achievementTime
                        )
                        completion(userData)
                    }
                }
            }
    }
    
}
