//
//  FirebaseManager.swift
//  Kiwee
//
//  Created by NY on 2024/5/19.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseStorage
import Combine

enum Collections: String {
    case intake = "intake"
    case users = "users"
    case posts = "posts"
    case faq = "FAQ"
}

protocol FirestoreCodable: Codable {
    var documentID: String? { get set }
}

class FirebaseManager {
    static let shared = FirebaseManager()
    let database = Firestore.firestore()
    let userID = Auth.auth().currentUser?.uid
    var listenerRegistration: ListenerRegistration?
    
    // MARK: - Get multiple Data
    func fetchData<T: Decodable>(from collection: Collections, queryOption: Query? = nil, completion: @escaping (Result<[T], Error>) -> Void) {
        var query: Query = database.collection(collection.rawValue)
        
        if let queryOption = queryOption {
            query = queryOption
        }
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let documents = querySnapshot?.documents.compactMap { documentSnapshot -> T? in
                    do {
                        return try documentSnapshot.data(as: T.self)
                    } catch {
                        print("Error decoding document into type \(T.self): \(error)")
                        return nil
                    }
                } ?? []
                completion(.success(documents))
            }
        }
    }
    
    // MARK: - Get DocumentID by userID
    func fetchDocumentID(UserID userID: String, collection: Collections, completion: @escaping (Result<String, Error>) -> Void) {
        let query = database.collection(collection.rawValue).whereField("id", isEqualTo: userID)
        
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else if let document = querySnapshot?.documents.first {
                let documentID = document.documentID
                completion(.success(documentID))
            }
        }
    }
    
    // MARK: - Snapshot listener
    func addSnapshotListener<T: Decodable>(for collection: Collections, queryOption: Query? = nil, completion: @escaping (Result<[T], Error>) -> Void) -> ListenerRegistration {
        var query: Query = database.collection(collection.rawValue)
        
        if let queryOption = queryOption {
            query = queryOption
        }
        
        return query.addSnapshotListener { (querySnapshot, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                let documents = querySnapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                completion(.success(documents))
            }
        }
    }
    
    // MARK: - Create Data
    func addData<T: Encodable>(to collection: Collections, data: T, completion: @escaping (Result<DocumentReference, Error>) -> Void) {
        var documentRef: DocumentReference?
        do {
            documentRef = try database.collection(collection.rawValue).addDocument(from: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else if let documentRef = documentRef {
                    completion(.success(documentRef))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Create multiple data with DocumentID
    func addDataBatch<T: FirestoreCodable>(to collection: Collections, dataArray: [T], completion: @escaping (Result<Bool, Error>) -> Void) {
        let batch = database.batch()

        var updatedDataArray = dataArray
        for (index, var data) in updatedDataArray.enumerated() {
            let documentRef = database.collection(collection.rawValue).document()
            data.documentID = documentRef.documentID
            updatedDataArray[index] = data

            do {
                let encodedData = try Firestore.Encoder().encode(data)
                batch.setData(encodedData, forDocument: documentRef)
            } catch {
                completion(.failure(error))
                return
            }
        }

        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    // MARK: - Update Data
    func updateData<T: Encodable>(in collection: Collections, documentID: String, data: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        do {
            let documentRef = database.collection(collection.rawValue).document(documentID)
            try documentRef.setData(from: data) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    // MARK: - Delete Data
    func deleteData(from collection: Collections, documentID: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        database.collection(collection.rawValue).document(documentID).delete { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    // MARK: - Delete Account Handle
    func setAccountDeletedStatus() {
        guard let userID = userID else { return }
        
        database.collection("users")
            .whereField("id", isEqualTo: userID)
            .getDocuments { querySnapshot, error in
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
                    print("No document found for user ID: \(userID)")
                }
            }
    }
    
}

// MARK: - Extension For Query
extension Firestore {
    
    func queryForUserIntake(userID: String, chosenDate: Date, type: String) -> Query {
        let startOfDay = Calendar.current.startOfDay(for: chosenDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return self.collection(Collections.intake.rawValue)
            .whereField("id", isEqualTo: userID)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .whereField("type", isEqualTo: type)
    }
    
    func queryForRecentRecord(userID: String, section: Int) -> Query {
        return self.collection(Collections.intake.rawValue)
            .whereField("id", isEqualTo: userID)
            .whereField("section", isEqualTo: section)
            .order(by: "date", descending: true)
            .limit(to: 10)
    }
    
    func queryForTodayIntake(userID: String, chosenDate: Date) -> Query {
        let startOfDay = Calendar.current.startOfDay(for: chosenDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return self.collection(Collections.intake.rawValue)
            .whereField("id", isEqualTo: userID)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
    }
    
    func queryForTotalCalories(userID: String) -> Query {
        return self.collection(Collections.intake.rawValue)
            .whereField("id", isEqualTo: userID)
            .order(by: "date")
    }
    
    func queryForUserCurrentWeight(userID: String, userDocumentID: String) -> Query {
        return self.collection(Collections.users.rawValue)
            .document(userDocumentID)
            .collection("current_weight")
            .order(by: "date")
    }
    
    func queryForPosts(userID: String) -> Query {
        return self.collection(Collections.posts.rawValue)
            .whereField("id", isEqualTo: userID)
            .order(by: "created_time")
    }
    
    func queryByOneField(userID: String, collection: Collections, field: String, fieldContent: String) -> Query {
        return self.collection(collection.rawValue)
            .whereField(field, isEqualTo: fieldContent)
    }
}
