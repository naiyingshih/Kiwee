//
//  ChartsViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import Foundation

struct PieChartData {
    var label: String
    var amount: Double
}

struct DataPoint {
    var date: Date
    var dataPoint: Double
}

struct BodyInfo {
    var initWeight: Double
    var goalWeight: Double
    var RDA: Double
}

class ChartsViewModel: ObservableObject {
    
    let firebaseManager = FirebaseManager.shared
    
    @Published var nutrientData: [PieChartData] = []
    @Published var caloriesData: [DataPoint] = []
    @Published var aggregatedCalorieDataPoints: [DataPoint] = []
    @Published var todayIntake: [PieChartData] = []
    @Published var userInputData: [DataPoint] = []
    @Published var calculatedBodyInfo: BodyInfo?
    
    init() {
        fetchNutrientData(forLastDays: Int())
        fetchCalorieData()
        getTodayIntake()
        fetchUserWeight()
        calculatedInfo()
    }
    
    func fetchNutrientData(forLastDays days: Int) {
        let dates = generateDateRange(from: days)
        var allFoods: [Food] = []
        let dispatchGroup = DispatchGroup()
        
        for date in dates {
            dispatchGroup.enter()
            let queryOptions = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: date, type: "food")
            firebaseManager.fetchData(from: .intake, queryOption: queryOptions) { (result: Result<[Food], Error>) in
                switch result {
                case .success(let foods):
                    allFoods.append(contentsOf: foods)
                case .failure(let error):
                    print("Error fetching foods: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.aggregateAndDisplayNutrientData(from: allFoods)
        }
    }
    
    private func generateDateRange(from daysAgo: Int) -> [Date] {
        var dates: [Date] = []
        for dayOffset in (0..<daysAgo).reversed() {
            if let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func aggregateAndDisplayNutrientData(from foods: [Food]) {
        var totalCarbohydrates: Double = 0
        var totalProtein: Double = 0
        var totalFat: Double = 0
        var totalFiber: Double = 0
        
        // Sum up nutrients
        for food in foods {
            totalCarbohydrates += food.nutrients.carbohydrates
            totalProtein += food.nutrients.protein
            totalFat += food.nutrients.fat
            totalFiber += food.nutrients.fiber
        }
        
        let aggregatedNutrientData = [
            PieChartData(label: "碳水", amount: totalCarbohydrates),
            PieChartData(label: "蛋白", amount: totalProtein),
            PieChartData(label: "脂肪", amount: totalFat),
            PieChartData(label: "纖維", amount: totalFiber)
        ]
        
        DispatchQueue.main.async {
            self.nutrientData = aggregatedNutrientData
        }
    }
    
    func fetchCalorieData() {
        FirestoreManager.shared.getOrderedDateData { [weak self] calories in
            DispatchQueue.main.async {
                self?.caloriesData = calories
                self?.aggregateCaloriesByDate()
            }
        }
    }
    
    private func aggregateCaloriesByDate() {
        var aggregatedData = [Date: Double]()

        for dataPoint in caloriesData {
            // Normalize the date to remove time part if necessary
            let date = Calendar.current.startOfDay(for: dataPoint.date)
            if let existingTotal = aggregatedData[date] {
                aggregatedData[date] = existingTotal + dataPoint.dataPoint
            } else {
                aggregatedData[date] = dataPoint.dataPoint
            }
        }
        
        let sortedAggregatedData = aggregatedData.sorted { $0.key < $1.key }
        self.aggregatedCalorieDataPoints = sortedAggregatedData.map { DataPoint(date: $0.key, dataPoint: $0.value) }
    }
    
    func getTodayIntake() {
        let foodQuery = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: Date(), type: "food")
        let waterQuery = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: Date(), type: "water")
        
        var newData: [PieChartData] = []
        firebaseManager.fetchData(from: .intake, queryOption: foodQuery) { (result: Result<[Food], Error>) in
            switch result {
            case .success(let foods):
                let totalCalories = foods.reduce(0) { $0 + $1.totalCalories }
                newData.append(PieChartData(label: "已攝取量", amount: totalCalories))
                self.todayIntake = newData
            case .failure(let error):
                print("Error fetching food data: \(error)")
            }
        }
        
        firebaseManager.fetchData(from: .intake, queryOption: waterQuery) { (result: Result<[WaterCount], Error>) in
            switch result {
            case .success(let waterCounts):
                let totalWater = waterCounts.first?.waterCount ?? 0
                newData.append(PieChartData(label: "已飲水量", amount: Double(totalWater * 250)))
                self.todayIntake = newData
            case .failure(let error):
                print("Error fetching water data: \(error)")
            }
        }
    }
    
    func fetchUserWeight() {
        FirestoreManager.shared.getUserWeight { [weak self] userInputs in
            DispatchQueue.main.async {
                self?.userInputData = userInputs
            }
        }
    }
    
    func calculatedInfo() {
        FirestoreManager.shared.getUserData { [weak self] userData in
            let RDA = BMRUtility.calculateBMR(with: userData)
            let bodyInfo = BodyInfo(initWeight: userData.initialWeight,
                                    goalWeight: userData.goalWeight,
                                    RDA: RDA
            )
            DispatchQueue.main.async {
                self?.calculatedBodyInfo = bodyInfo
            }
        }
    }

}
