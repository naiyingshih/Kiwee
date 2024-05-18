//
//  AddFoodViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/5/16.
//

import Foundation

protocol AddFoodViewControllerDelegate: AnyObject {
    func didUpdateFilteredFoodItems(_ foodItems: [Food])
    func didUpdateRecentFoods(_ items: [Food])
    func didConfirmFoodItems(_ foodItems: [Food])
}

class AddFoodViewModel {
    
    weak var delegate: AddFoodViewControllerDelegate?
    
    var foodResult: [Food] = []
    var filteredFoodItems: [Food] = [] {
        didSet {
            delegate?.didUpdateFilteredFoodItems(filteredFoodItems)
        }
    }
    var searchFoodResult: [Food] = []
    var recentFoods: [Food] = [] {
        didSet {
            delegate?.didUpdateRecentFoods(recentFoods)
        }
    }
    var sectionIndex: Int?
    var currentMethod: AddFoodMethod?
    var selectedDate: Date?
    var foodQuantities: [String: Double] = [:]
    
    // MARK: - Data Fetching and Processing
    func fetchRecentRecord() {
        guard let section = sectionIndex else { return }
        FirestoreManager.shared.getFoodSectionData(section: section) { [weak self] foods in
            guard let self = self else { return }
            self.recentFoods = self.processRecentFoods(foods)
        }
    }
    
    private func processRecentFoods(_ foods: [Food]) -> [Food] {
        return foods.map { food in
            var modifiedFood = food
            if modifiedFood.quantity != 0 {
                modifiedFood.totalCalories = ((modifiedFood.totalCalories * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                modifiedFood.nutrients.carbohydrates = ((modifiedFood.nutrients.carbohydrates * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                modifiedFood.nutrients.protein = ((modifiedFood.nutrients.protein * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                modifiedFood.nutrients.fat = ((modifiedFood.nutrients.fat * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
                modifiedFood.nutrients.fiber = ((modifiedFood.nutrients.fiber * 100) / (modifiedFood.quantity ?? 100) * 10).rounded() / 10
            }
            return modifiedFood
        }
    }
    
    func calculateIntakeData(for food: Food, quantity: Double) -> Food? {
        let updatedTotalCalorie = (food.totalCalories * (quantity / 100.0) * 10).rounded() / 10
        let updatedCarbohydrates = (food.nutrients.carbohydrates * (quantity / 100.0) * 10).rounded() / 10
        let updatedProtein = (food.nutrients.protein * (quantity / 100.0) * 10).rounded() / 10
        let updatedFat = (food.nutrients.fat * (quantity / 100.0) * 10).rounded() / 10
        let updatedFiber = (food.nutrients.fiber * (quantity / 100.0) * 10).rounded() / 10
        
        let nutrients = Food.Nutrient(carbohydrates: updatedCarbohydrates, protein: updatedProtein, fat: updatedFat, fiber: updatedFiber)
        
        guard let sectionIndex = self.sectionIndex else {
            return nil
        }
        
        return Food(
            documentID: food.documentID,
            name: food.name,
            totalCalories: updatedTotalCalorie,
            nutrients: nutrients,
            image: food.image,
            quantity: quantity,
            section: sectionIndex,
            date: food.date
        )
    }
    
    func loadFood() {
        FoodDataManager.shared.loadFood { [weak self] (foodItems, error) in
            if let foodItems = foodItems {
                guard let self = self else { return }
                self.foodResult = foodItems
            } else if let error = error {
                print("Failed to load food data: \(error)")
            }
        }
    }
    
    func addIdentifiedFood(name: String, totalCalories: Double, nutrients: Food.Nutrient, image: String) {
        let newFood = Food(
            documentID: "",
            name: name,
            totalCalories: totalCalories,
            nutrients: nutrients,
            image: image,
            quantity: nil,
            section: nil,
            date: nil
        )
        DispatchQueue.main.async {
            self.filteredFoodItems.insert(newFood, at: 0)
        }
    }
    
    // MARK: - Actions
    func confirmed(getCellAndQuantity: (_ rowIndex: Int, _ filteredFoodItem: Food) -> (cell: ResultCell?, quantity: Double?)?) {
        guard !filteredFoodItems.isEmpty else { return }
        
        var calculatedIntakeDataArray: [Food] = []
        
        for (rowIndex, filteredFoodItem) in filteredFoodItems.enumerated() {
            if let (_, quantity) = getCellAndQuantity(rowIndex, filteredFoodItem),
               let calculatedIntakeData = calculateIntakeData(for: filteredFoodItem, quantity: quantity ?? 100.0) {
                calculatedIntakeDataArray.append(calculatedIntakeData)
            }
        }
        
        FirestoreManager.shared.postIntakeData(
            intakeDataArray: calculatedIntakeDataArray,
            chosenDate: selectedDate ?? Date()
        ) { [weak self] success in
            if success {
                print("Food intake data posted successfully")
                self?.delegate?.didConfirmFoodItems(calculatedIntakeDataArray)
            } else {
                print("Failed to post food intake data")
            }
        }
    }
}
