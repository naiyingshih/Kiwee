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

class ChartsViewModel: ObservableObject {
    
    @Published var nutrientData: [ChartData] = []
//    @Published var selectedChartData: ChartData?
    
    init() {
        fetchNutrientData(day: Int())
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
                print("===\(String(describing: self?.nutrientData))")
            }
        }
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
    
    let caloriesData: [ChartData] = [
        .init(label: "4/8", amount: 1100),
        .init(label: "4/10", amount: 900),
        .init(label: "4/13", amount: 1600),
        .init(label: "4/15", amount: 1300),
        .init(label: "4/16", amount: 1200)
    ]
    
}
