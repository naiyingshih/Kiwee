//
//  ChartsViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import Foundation

class ChartsViewModel: ObservableObject{
    @Published var graphType: GraphType = GraphType()
}

struct GraphType: Equatable{
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
    .init(label: "已攝取量", amount: 68.9),
    .init(label: "剩餘攝取量", amount: 31.1)
]
