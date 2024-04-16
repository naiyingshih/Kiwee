//
//  CaloriesChartView.swift
//  Kiwee
//
//  Created by NY on 2024/4/16.
//

import SwiftUI
import Charts

struct CaloriesChartView: View {
    
    @StateObject var viewModel = ChartsViewModel()
    
    @State private var selectedTimeRange: TimeRange = .last7Days
    
    var body: some View {
          VStack {
              // Title
              Text("熱量報告")
                  .font(.title2)
                  .bold()
                  .padding()
              
              // Chart
              Chart(viewModel.aggregatedCalorieDataPoints, id: \.date) { element in
                  LineMark(
                      x: .value("日期", element.date),
                      y: .value("熱量", element.calories)
                  )
                  .interpolationMethod(.catmullRom)
                  
                  PointMark(
                      x: .value("日期", element.date),
                      y: .value("熱量", element.calories)
                  )
                  .foregroundStyle(by: .value("熱量", element.calories))
                  
                  RuleMark(y: .value("熱量", 1500))
                      .foregroundStyle(.gray)
                      .annotation(position: .top,
                                  alignment: .topLeading) {
                          Text("建議攝取量: 1500 kcal")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
                      }
              }
              .frame(height: 200)
              .chartScrollableAxes(.horizontal)
          }
          .padding()
      }
    
}
