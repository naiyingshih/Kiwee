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
        
        database.collection("users")
            .whereField("id", isEqualTo: input.id)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    completion(false)
                } else if let querySnapshot = querySnapshot, querySnapshot.documents.isEmpty {
                    self.database.collection("users").addDocument(data: userDictionary) { error in
                        if let error = error {
                            print("Error adding user data: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            print("User data added successfully")
                            completion(true)
                        }
                    }
                } else {
                    if let document = querySnapshot?.documents.first {
                        document.reference.updateData(userDictionary) { error in
                            if let error = error {
                                print("Error updating user data: \(error.localizedDescription)")
                                completion(false)
                            } else {
                                print("User data updated successfully")
                                completion(true)
                            }
                        }
                    }
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
    
    func updateAccountStatus() {
        guard let currentUserUID = userID else { return }
        
        database.collection("users").whereField("id", isEqualTo: currentUserUID).getDocuments { querySnapshot, error in
            if let error = error {
                print("Error finding user document: \(error.localizedDescription)")
            } else if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                let document = querySnapshot.documents.first
                document?.reference.updateData(["status": "delete"]) { error in
                    if let error = error {
                        print("Error updating document: \(error.localizedDescription)")
                    } else {
                        print("Account status updated successfully")
                    }
                }
            } else {
                print("No document found for user ID: \(currentUserUID)")
            }
        }
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
    
    func publishFoodCollection(foodName: String, tag: String, imageUrl: String, completion: @escaping (Bool) -> Void) {
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
                completion(false)
            } else {
                print("Document added to post successfully")
                completion(true)
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
