//
//  FirebaseQuery +Ext.swift
//  Kiwee
//
//  Created by NY on 2024/5/25.
//

import Foundation
import Firebase
import FirebaseFirestore

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
