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
    
}
