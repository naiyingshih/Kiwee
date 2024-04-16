//
//  ChartsViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import Foundation

// class ChartsViewModel: ObservableObject {
//    @Published var graphType: GraphType = GraphType()
// }
//
// struct GraphType: Equatable {
//    var isBarChart: Bool = false
//    var isProgressChart: Bool = false
//    var isPieChart: Bool = true
//    var isLineChart: Bool = false
// }

struct ChartData {
    var label: String
    var amount: Double
}

let nutrientData: [ChartData] = [
    .init(label: "碳水", amount: 26.5),
    .init(label: "蛋白", amount: 25.0),
    .init(label: "脂肪", amount: 45.0),
    .init(label: "纖維", amount: 3.5)
]

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
