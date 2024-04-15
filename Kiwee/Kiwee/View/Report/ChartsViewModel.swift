//
//  ChartsViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import Foundation

class ChartsViewModel: ObservableObject {
    @Published var graphType: GraphType = GraphType()
}

struct GraphType: Equatable {
    var isBarChart: Bool = false
    var isProgressChart: Bool = false
    var isPieChart: Bool = true
    var isLineChart: Bool = false
}

struct ChartData {
    var label: String
    var amount: Double
}

let data: [ChartData] = [
    .init(label: "碳水", amount: 26.5),
    .init(label: "蛋白", amount: 25.0),
    .init(label: "脂肪", amount: 45.0),
    .init(label: "纖維", amount: 3.5)
]
