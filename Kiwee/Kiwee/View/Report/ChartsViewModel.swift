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
    
    @Published var nutrientData: [PieChartData] = []
    @Published var caloriesData: [DataPoint] = []
    @Published var aggregatedCalorieDataPoints: [DataPoint] = []
    @Published var todayIntake: [PieChartData] = []
    @Published var userInputData: [DataPoint] = []
    @Published var calculatedBodyInfo: BodyInfo?
    
    init() {
        fetchNutrientData(day: Int())
        fetchCalorieData()
        getTodayIntake()
        fetchUserWeight()
        calculatedInfo()
    }
    
    func fetchNutrientData(day: Int) {
        FirestoreManager.shared.fetchAndAggregateData(forLastDays: day) { [weak self] (foods, _) in
            
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
                self?.nutrientData = aggregatedNutrientData
            }
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
        FirestoreManager.shared.getIntakeCard(collectionID: "intake", chosenDate: Date()) { [weak self] foods, water in
            var newData: [PieChartData] = []
            let totalCalories = foods.reduce(0) { $0 + $1.totalCalories }
            newData.append(PieChartData(label: "已攝取量", amount: totalCalories))
            newData.append(PieChartData(label: "已飲水量", amount: Double(water * 250)))
            
            DispatchQueue.main.async {
                self?.todayIntake = newData
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
            let bodyInfo = BodyInfo(initWeight: userData.initialWeight,
                                    goalWeight: userData.goalWeight,
                                    RDA: (userData.height * userData.height) / 10000 * 22 * 25
            )
            DispatchQueue.main.async {
                self?.calculatedBodyInfo = bodyInfo
            }
        }
    }

}
