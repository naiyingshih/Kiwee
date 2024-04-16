//
//  DecodeManager.swift
//  Kiwee
//
//  Created by NY on 2024/4/13.
//

import Foundation

class FoodDataManager {
    static let shared = FoodDataManager()
    
    func loadFood(completion: @escaping ([Food]?, Error?) -> Void) {
        // Load JSON data from file
        if let url = Bundle.main.url(forResource: "FoodData", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let foodResult = try decoder.decode([Food].self, from: data)
                completion(foodResult, nil)
            } catch {
                print("Error decoding JSON: \(error)")
                completion(nil, error)
            }
        }
    }
}
