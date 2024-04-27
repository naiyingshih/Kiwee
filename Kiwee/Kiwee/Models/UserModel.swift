//
//  UserModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/17.
//

import Foundation

struct UserData {
    let id: String
    let name: String
    let gender: Int
    let age: Int
    let goal: Int
    let activeness: Int
    let height: Double
    let initialWeight: Double
    let updatedWeight: Double?
    let goalWeight: Double
    let achievementTime: Date
}

struct Post {
    let documenID: String
    var foodName: String
    var tag: String
    var image: String
    let createdTime: Date
}
