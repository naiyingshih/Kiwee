//
//  DiaryViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/5/15.
//

import Foundation

class DiaryViewModel {
    
    var allFood: [[Food]] = Array(repeating: [], count: 5)
    var waterCount: Int = 0
    
    var reloadData: (() -> Void)?
    var updateWaterSection: (() -> Void)?
    
    // MARK: - Fetch data functions
    func loadData(for date: Date) {
        FirestoreManager.shared.getIntakeCard(collectionID: "intake", chosenDate: date) { [weak self] foods, water in
            self?.organizeAndDisplayFoods(foods: foods)
            self?.waterCount = water
            self?.reloadData?()
        }
    }
    
    private func organizeAndDisplayFoods(foods: [Food]) {
        var newAllFood: [[Food]] = Array(repeating: [], count: 5)
        for food in foods {
            guard let section = food.section, section >= 0, section < newAllFood.count else { continue }
            newAllFood[section].append(food)
        }
        self.allFood = newAllFood
    }
    
    func addWaterCount() {
        waterCount += 1
        updateWaterSection?()
    }
    
    func postWaterCount(chosenDate: Date, completion: @escaping (Bool) -> Void) {
        FirestoreManager.shared.postWaterCount(waterCount: self.waterCount, chosenDate: chosenDate) { success in
            completion(success)
        }
    }
    
    func deleteFoodItem(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let foodItem = allFood[indexPath.section][indexPath.row]
        guard let documentID = foodItem.documentID else {
            completion(false)
            return
        }
        
        FirestoreManager.shared.deleteDocument(collectionID: "intake", documentID: documentID) { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
    func resetWaterCount(chosenDate: Date, completion: @escaping (Bool) -> Void) {
        FirestoreManager.shared.resetWaterCount(chosenDate: chosenDate) { success in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }
    
}
