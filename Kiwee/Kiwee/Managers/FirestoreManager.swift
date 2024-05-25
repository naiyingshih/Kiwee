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
    
}
