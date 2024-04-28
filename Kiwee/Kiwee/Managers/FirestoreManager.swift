//
//  FirebaseManager.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage

class FirestoreManager {
    static let shared = FirestoreManager()
    let database = Firestore.firestore()
    let userID = Auth.auth().currentUser?.uid
    
    func deleteDocument(collectionID: String, documentID: String, completion: @escaping (Bool) -> Void) {
        database.collection(collectionID).document(documentID).delete { error in
            if let error = error {
                print("Error removing document: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
}

// MARK: - User data
extension FirestoreManager {
    
    func postUserData(input: UserData, completion: @escaping (Bool) -> Void) {
        let userDictionary: [String: Any] = [
            "id": input.id,
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
                completion(true)
            }
        }
    }
    
    func updatePartialUserData(updates: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        database.collection("users")
            .whereField("id", isEqualTo: currentUserUID)
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
                    print("No document found with the id: \(currentUserUID)")
                    completion(false)
                }
            }
    }
    
    func getUserData(completion: @escaping (UserData) -> Void) {
        guard let currentUserUID = userID else { return }
        
        database.collection("users")
            .whereField("id", isEqualTo: currentUserUID)
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let id = currentUserUID
                        let name = data["name"] as? String ?? ""
                        let gender = data["gender"] as? Int ?? 0
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

// MARK: - Food and Water
    
extension FirestoreManager {
    
    func postWaterCount(waterCount: Int, chosenDate: Date, completion: @escaping (Bool) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: chosenDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        database.collection("intake")
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
                    let documentID = self.database.collection("intake").document().documentID
                    let waterDictionary: [String: Any] = [
                        "id": currentUserUID,
                        "water_count": waterCount,
                        "date": chosenDate,
                        "type": "water",
                        "documentID": documentID
                    ]
                    
                    // Use the documentID to set the document with the specific ID
                    self.database.collection("intake").document(documentID).setData(waterDictionary) { error in
                        if let error = error {
                            print("Error adding water intake: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("Water intake data added successfully with ID: \(documentID)")
                            completion(true)
                        }
                    }
                }
            }
    }
    
    func postIntakeData(intakeDataArray: [Food], chosenDate: Date, completion: @escaping (Bool) -> Void) {
        guard let currentUserUID = userID else { return }
        let batch = database.batch()
        
        for intakeData in intakeDataArray {
            let intakeRef = database.collection("intake").document() // Create a new document reference for each food item
            let intakeDictionary: [String: Any] = [
                "id": currentUserUID,
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
                "type": "food",
                "documentID": intakeRef.documentID
            ]
            batch.setData(intakeDictionary, forDocument: intakeRef) // Add each food item to the batch
        }
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("Error writing batch \(error.localizedDescription)")
                completion(false)
            } else {
                print("Batch write succeeded.")
                completion(true)
            }
        }
    }
    
    func resetWaterCount(chosenDate: Date, completion: @escaping (Bool) -> Void) {
        let startOfDay = Calendar.current.startOfDay(for: chosenDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        database.collection("intake")
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("type", isEqualTo: "water")
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.database.collection("intake").document(document.documentID).delete { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                                completion(false)
                            } else {
                                completion(true)
                            }
                        }
                    }
                }
            }
    }
    
    func getIntakeCard(collectionID: String, chosenDate: Date, completion: @escaping ([Food], Int) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
       
        let startOfDay = Calendar.current.startOfDay(for: chosenDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        database.collection(collectionID)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("id", isEqualTo: currentUserUID)
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
            guard let foodData = document["nutrients"] as? [String: Any],
                  let name = document["name"] as? String,
                  let totalCalories = document["totalCalories"] as? Double,
                  let image = document["image"] as? String,
                  let quantity = document["quantity"] as? Double,
                  let section = document["section"] as? Int,
                  let date = document["date"] as? Timestamp,
                  let documentID = document["documentID"] as? String else {
                continue // Skip this document if any of the required fields are missing
            }
            
            let carbohydrates = foodData["carbohydrates"] as? Double
            let protein = foodData["protein"] as? Double
            let fat = foodData["fat"] as? Double
            let fiber = foodData["fiber"] as? Double
            
            guard let carbs = carbohydrates, let prot = protein, let fats = fat, let fib = fiber else {
                continue
            }
            let dateValue = date.dateValue()
            let nutrientInfo = Nutrient(carbohydrates: carbs, protein: prot, fat: fats, fiber: fib)
            foodsForToday.append(Food(documentID: documentID,
                                      name: name,
                                      totalCalories: totalCalories,
                                      nutrients: nutrientInfo,
                                      image: image,
                                      quantity: quantity,
                                      section: section,
                                      date: dateValue)
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
    
}
    
// MARK: - Posts in profile
    
extension FirestoreManager {
    
    func uploadImageData(imageData: Data, completion: @escaping (Bool, URL?) -> Void) {
        let fileName = "postImage_\(UUID().uuidString).jpg"
        
        let storageReference = Storage.storage().reference().child("images/\(fileName)")
        storageReference.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(false, nil)
                return
            }
            print("Image file: \(fileName) is uploaded!")
            
            storageReference.downloadURL { (url, error) in
                if let error = error {
                    print("Error on getting download url: \(error.localizedDescription)")
                    completion(false, nil)
                    return
                }
                if let downloadURL = url {
                    print("Download url of \(fileName) is \(downloadURL.absoluteString)")
                    completion(true, downloadURL)
                } else {
                    completion(false, nil)
                }
            }
        }
    }
    
    func publishFoodCollection(foodName: String, tag: String, imageUrl: String) {
        let documentID = database.collection("posts").document().documentID
        let publishData: [String: Any] = [
            "id": userID as Any,
            "documentID": documentID,
            "food_name": foodName,
            "tag": tag,
            "image": imageUrl,
            "created_time": FieldValue.serverTimestamp()
        ]
        database.collection("posts").document(documentID).setData(publishData) { error in
            if let error = error {
                print("Error adding document to subcollection: \(error.localizedDescription)")
            } else {
                print("Document added to post successfully")
            }
        }
    }
    
    func updateFoodCollection(documentID: String, foodName: String, tag: String, completion: @escaping () -> Void) {
        let updateData: [String: Any] = [
            "food_name": foodName,
            "tag": tag
        ]
           
        database.collection("posts").document(documentID).updateData(updateData) { error in
            if let error = error {
                print("Error updating document: \(error.localizedDescription)")
            } else {
                print("Document updated successfully")
                completion()
            }
        }
    }
    
    func getPostData(completion: @escaping ([Post]) -> Void) {
        guard let currentUserUID = userID else {
             print("Error: User not logged in")
             completion([])
             return
         }
        
        database.collection("posts")
            .whereField("id", isEqualTo: currentUserUID)
            .order(by: "created_time")
            .addSnapshotListener { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                } else {
                    var posts: [Post] = []
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        guard let foodName = data["food_name"] as? String,
                              let image = data["image"] as? String,
                              let tag = data["tag"] as? String,
                              let createdTime = data["created_time"] as? Timestamp else { continue }
                        
                        let post = Post(documenID: document.documentID, foodName: foodName, tag: tag, image: image, createdTime: createdTime.dateValue())
                        posts.insert(post, at: 0)
                    }
                    completion(posts)
                }
            }
    }
    
}
    
// MARK: - Report
    
extension FirestoreManager {
    
    func postWeightToSubcollection(weight: Double) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        let weightData: [String: Any] = [
            "weight": weight,
            "date": FieldValue.serverTimestamp()
        ]
        
        database.collection("users")
            .whereField("id", isEqualTo: currentUserUID)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error finding user document: \(error.localizedDescription)")
                } else if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                    // Each UID is unique and can only match one document
                    let userDocument = querySnapshot.documents.first
                    
                    // Get the document ID of the matching document
                    if let userDocumentId = userDocument?.documentID {
                        self.database.collection("users").document(userDocumentId).collection("current_weight")
                            .addDocument(data: weightData) { error in
                                if let error = error {
                                    print("Error adding document to subcollection: \(error.localizedDescription)")
                                } else {
                                    print("Document added to subcollection successfully")
                                }
                            }
                    }
                } else {
                    print("No matching user document found")
                }
            }
    }
    
    func getUserWeight(completion: @escaping ([DataPoint]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in")
            completion([])
            return
        }
        database.collection("users").whereField("id", isEqualTo: currentUserUID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error finding user document: \(error.localizedDescription)")
                completion([])
            } else if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                // Each UID is unique and can only match one document
                let userDocument = querySnapshot.documents.first
                
                // Get the document ID of the matching document
                if let userDocumentId = userDocument?.documentID {
                    self.database.collection("users").document(userDocumentId).collection("current_weight")
                        .order(by: "date")
                        .addSnapshotListener { (subQuerySnapshot, subError) in
                            if let subError = subError {
                                print("Error getting documents from subcollection: \(subError)")
                                completion([])
                            } else {
                                var dataPoints: [DataPoint] = []
                                for document in subQuerySnapshot!.documents {
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
                } else {
                    print("No matching user document found")
                    completion([])
                }
            } else {
                print("No matching user document found")
                completion([])
            }
        }
    }
    
    func getOrderedDateData(completion: @escaping ([DataPoint]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        database.collection("intake")
            .whereField("id", isEqualTo: currentUserUID)
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
}
    
// MARK: - Recent Record

extension FirestoreManager {
    
    func getFoodSectionData(section: Int, completion: @escaping ([Food]) -> Void) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        database.collection("intake")
            .whereField("id", isEqualTo: currentUserUID)
            .whereField("section", isEqualTo: section)
            .order(by: "date", descending: true)
            .limit(to: 6)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                } else {
                    var foodsDict = [String: Food]()
                    let foods = self.getIntake(from: querySnapshot?.documents ?? [])
                    for food in foods {
                        if let existingFood = foodsDict[food.name] {
                            if food.date ?? Date() > existingFood.date ?? Date() {
                                foodsDict[food.name] = food
                            }
                        } else {
                            foodsDict[food.name] = food
                        }
                    }
                    // Convert the dictionary back to an array
                    let uniqueSortedFoods = Array(foodsDict.values).sorted(by: { $0.date ?? Date() > $1.date ?? Date() })
                    completion(uniqueSortedFoods)
                }
            }
    }
}
    
// MARK: - Chatbot Response

extension FirestoreManager {

    func getResponse(sendMessage: String, completion: @escaping([MessageRow]) -> Void) {
        database.collection("FAQ")
            .whereField("send_message", isEqualTo: sendMessage)
            .getDocuments { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([])
                } else {
                    var messages = [MessageRow]()
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        let responses = data["response_message"] as? [String] ?? []
                        for response in responses {
                            let message = MessageRow(
                                isInteractingWithChatGPT: false,
                                sendText: sendMessage,
                                responseText: response,
                                responseError: nil
                            )
                            messages.append(message)
                            
                        }
                        completion(messages)
                        print(messages)
                    }
                }
            }
    }
    
}
