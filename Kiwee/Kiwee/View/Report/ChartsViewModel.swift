//
//  ChartsViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import Foundation

struct ChartData {
    var label: String
    var amount: Double
}

struct CalorieDataPoint {
    var date: String
    var calories: Double
}

class ChartsViewModel: ObservableObject {
    
    @Published var nutrientData: [ChartData] = []
    @Published var caloriesData: [CalorieDataPoint] = []
    @Published var aggregatedCalorieDataPoints: [CalorieDataPoint] = []
//    @Published var selectedChartData: ChartData?
    
    init() {
        fetchNutrientData(day: Int())
        fetchCalorieData()
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
                ChartData(label: "碳水", amount: totalCarbohydrates),
                ChartData(label: "蛋白", amount: totalProtein),
                ChartData(label: "脂肪", amount: totalFat),
                ChartData(label: "纖維", amount: totalFiber)
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
        var aggregatedData = [String: Double]()
        
        for dataPoint in caloriesData {
            if let existingTotal = aggregatedData[dataPoint.date] {
                aggregatedData[dataPoint.date] = existingTotal + dataPoint.calories
            } else {
                aggregatedData[dataPoint.date] = dataPoint.calories
            }
        }
        
        let sortedAggregatedData = aggregatedData.sorted { $0.key < $1.key }
        self.aggregatedCalorieDataPoints = sortedAggregatedData.map { CalorieDataPoint(date: $0.key, calories: $0.value) }
    }

//    func selectChartData(_ chartData: ChartData) {
//        selectedChartData = chartData
//    }
       
    let weightData: [ChartData] = [
        .init(label: "4/6", amount: 60),
        .init(label: "4/10", amount: 55),
        .init(label: "4/12", amount: 54),
        .init(label: "4/15", amount: 53)
    ]
    
}
