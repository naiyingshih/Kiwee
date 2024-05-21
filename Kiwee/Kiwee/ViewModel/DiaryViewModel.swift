//
//  DiaryViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/5/15.
//

import Foundation

class DiaryViewModel: ObservableObject {
    
    let firebaseManager = FirebaseManager.shared

    var allFood: [[Food]] = Array(repeating: [], count: 5) {
        didSet {
            DispatchQueue.main.async {
                self.reloadData?()
            }
        }
    }
    
    var waterCount: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.reloadData?()
            }
        }
    }
    
    var reloadData: (() -> Void)?
    var updateWaterSection: (() -> Void)?
    
    // MARK: - Fetch data functions
    func loadData(for date: Date) {
        fetchWaterCount(chosenDate: date) { _ in }
        fetchFoodData(chosenDate: date) { _ in }
    }
    
    // MARK: - Water data handling
    func addWaterCount() {
        waterCount += 1
        updateWaterSection?()
    }

    private func fetchWaterCount(chosenDate: Date, completion: @escaping (Bool) -> Void) {
        let queryOptions = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: chosenDate, type: "water")
        
        firebaseManager.fetchData(from: .intake, queryOption: queryOptions) { [weak self] (result: Result<[WaterCount], Error>) in
            switch result {
            case .success(let waterCounts):
                if let firstWaterCount = waterCounts.first {
                    self?.waterCount = firstWaterCount.waterCount
                    completion(true)
                } else {
                    self?.waterCount = 0
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    func postWaterCount(chosenDate: Date, completion: @escaping (Bool) -> Void) {
        let queryOptions = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: chosenDate, type: "water")
        
        firebaseManager.fetchData(from: .intake, queryOption: queryOptions) { [weak self] (result: Result<[WaterCount], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let waterCounts):
                if let firstWaterCount = waterCounts.first {
                    self.updateWaterCount(documentID: firstWaterCount.documentID, waterCount: self.waterCount, chosenDate: chosenDate, completion: completion)
                } else {
                    self.createWaterDocument(userID: firebaseManager.userID ?? "", waterCount: self.waterCount, chosenDate: chosenDate, completion: completion)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    private func updateWaterCount(documentID: String, waterCount: Int, chosenDate: Date, completion: @escaping (Bool) -> Void) {
        let waterCountData = WaterCount(id: firebaseManager.userID ?? "", waterCount: waterCount, date: chosenDate, documentID: documentID)
        firebaseManager.updateData(in: .intake, documentID: documentID, data: waterCountData) { result in
            switch result {
            case .success:
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    private func createWaterDocument(userID: String, waterCount: Int, chosenDate: Date, completion: @escaping (Bool) -> Void) {
        var waterCountData = WaterCount(id: userID, waterCount: waterCount, date: chosenDate, documentID: "")

        firebaseManager.addData(to: .intake, data: waterCountData) { [weak self] result in
            switch result {
            case .success(let documentRef):
                let documentID = documentRef.documentID
                waterCountData.documentID = documentID
                
                self?.firebaseManager.updateData(in: .intake, documentID: documentID, data: waterCountData) { updateResult in
                    switch updateResult {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    func resetWaterCount(chosenDate: Date, completion: @escaping (Bool) -> Void) {
        let query = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: chosenDate, type: "water")
        
        firebaseManager.fetchData(from: .intake, queryOption: query) { [weak self] (result: Result<[WaterCount], Error>) in
            switch result {
            case .success(let documents):
                if let documentID = documents.first?.documentID {
                    self?.deleteWaterDocument(documentID: documentID, completion: completion)
                } else {
                    completion(true)
                }
            case .failure(let error):
                print("Error getting documents: \(error.localizedDescription)")
                completion(false)
            }
        }
    }

    private func deleteWaterDocument(documentID: String, completion: @escaping (Bool) -> Void) {
        firebaseManager.deleteData(from: .intake, documentID: documentID) { result in
            switch result {
            case .success:
                self.waterCount = 0
                completion(true)
            case .failure(let error):
                print("Error deleting document: \(error.localizedDescription)")
                completion(false)
            }
        }
    }
    
    // MARK: - Food data handling
    private func fetchFoodData(chosenDate: Date, completion: @escaping (Bool) -> Void) {
        let queryOptions = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: chosenDate, type: "food")
        
        firebaseManager.listenerRegistration = firebaseManager.addSnapshotListener(for: .intake, queryOption: queryOptions) { [weak self] (result: Result<[Food], Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let foods):
                self.organizeAndDisplayFoods(foods: foods)
                completion(true)
            case .failure:
                completion(false)
            }
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
    
    func deleteFoodItem(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let foodItem = allFood[indexPath.section][indexPath.row]
        guard let documentID = foodItem.documentID else {
            completion(false)
            return
        }
        
        firebaseManager.deleteData(from: .intake, documentID: documentID) { _ in
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
}
