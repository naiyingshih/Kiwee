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
    var date: Date
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
        var aggregatedData = [Date: Double]()

        for dataPoint in caloriesData {
            // Normalize the date to remove time part if necessary
            let date = Calendar.current.startOfDay(for: dataPoint.date)
            if let existingTotal = aggregatedData[date] {
                aggregatedData[date] = existingTotal + dataPoint.calories
            } else {
                aggregatedData[date] = dataPoint.calories
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
        .init(label: "4/16", amount: 57),
        .init(label: "4/28", amount: 54),
        .init(label: "4/30", amount: 53)
    ]
    
}
