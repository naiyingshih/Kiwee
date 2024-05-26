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
    var userID = Auth.auth().currentUser?.uid
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
    
    // MARK: - Add data to subcollection
    func addDataToSub<T: Encodable>(to collection: Collections, documentID: String, subcollection: String, data: T, completion: @escaping (Result<DocumentReference, Error>) -> Void) {
        var documentRef: DocumentReference?
        do {
            documentRef = try database.collection(collection.rawValue).document(documentID).collection(subcollection).addDocument(from: data) { error in
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
    
}

// MARK: - Extension For Firebase Storgae
extension FirebaseManager {
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
}

// MARK: - Extension For custom functions
extension FirebaseManager {
    func updatePost(documentID: String, foodName: String, tag: String, completion: @escaping () -> Void) {
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
    
    func updatePartialUserData(userID: String, updates: [String: Any], completion: @escaping (Bool) -> Void) {
        database.collection("users")
            .whereField("id", isEqualTo: userID)
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
                    print("No document found with the id: \(userID)")
                    completion(false)
                }
            }
    }
    
}
