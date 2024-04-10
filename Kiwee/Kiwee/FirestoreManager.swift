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
    let db = Firestore.firestore()
    
    func get(collectionID: String, completion: @escaping ([Food]) -> Void) {
        db.collection("foods").addSnapshotListener { querySnapshot, err in
            if let error = err {
                print(error)
                completion([])
            } else {
                completion(Food.build(from: querySnapshot?.documents ?? []))
            }
        }
    }
}
