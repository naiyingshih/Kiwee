//
//  UserModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/17.
//

import Foundation

struct UserData: Decodable {
    var id: String
    var name: String
    var gender: Int
    var age: Int
    var goal: Int
    var activeness: Int
    var height: Double
    var initialWeight: Double
    var updatedWeight: Double?
    var goalWeight: Double
    var achievementTime: Date
    var documentID: String?
    var date: Date?
    
    enum CodingKeys: String, CodingKey {
        case id, name, gender, age, goal, activeness, height, documentID, date
        case initialWeight = "initial_weight"
        case updatedWeight = "updated_weight"
        case goalWeight = "goal_weight"
        case achievementTime = "achievement_time"
    }
}

struct WeightData: Decodable {
    var date: Date?
    var weight: Double?
}

struct Post {
    let documenID: String
    var foodName: String
    var tag: String
    var image: String
    let createdTime: Date
}
