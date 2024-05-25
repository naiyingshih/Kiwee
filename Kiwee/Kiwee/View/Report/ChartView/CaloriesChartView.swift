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
    
    var body: some View {
          VStack {
              // Title
              Text("熱量報告")
                  .font(.title2)
                  .bold()
                  .padding()
              
              if viewModel.aggregatedCalorieDataPoints.isEmpty {
                  // Display default text when there is no data
                  Text("還沒有熱量紀錄哦！")
                      .font(.title3)
                      .foregroundColor(.gray)
              } else {
                  // Chart
                  Chart(viewModel.aggregatedCalorieDataPoints, id: \.date) { element in
                      LineMark(
                        x: .value("日期", element.date),
                        y: .value("熱量", element.dataPoint)
                      )
                      .interpolationMethod(.catmullRom)
                      .foregroundStyle(Color(hex: "DBEC90"))
                      .lineStyle(StrokeStyle(lineWidth: 2))
                      
                      PointMark(
                        x: .value("日期", element.date),
                        y: .value("熱量", element.dataPoint)
                      )
                      .foregroundStyle(Color(hex: "BEDB39"))
                      .annotation(position: .topTrailing, alignment: .center) {
                          Text("\(element.dataPoint, specifier: "%.0f")")
                              .font(.caption)
                              .foregroundColor(.black)
                      }
                      
                      let RDA = viewModel.calculatedBodyInfo?.RDA
                      RuleMark(y: .value("熱量", RDA ?? 0))
                          .foregroundStyle(.gray)
                          .lineStyle(StrokeStyle(lineWidth: 1))
                          .annotation(position: .top,
                                      alignment: .topLeading) {
                              Text("建議攝取量:\(RDA ?? 0, specifier: "%.0f") kcal")
                                  .font(.system(size: 12))
                                  .foregroundColor(.gray)
                          }
                  }
                  .padding([.all])
                  .frame(height: 200)
                  .chartScrollableAxes(.horizontal)
                  .chartXVisibleDomain(length: 365000)
                  .chartXAxis {
                      AxisMarks(preset: .aligned, position: .bottom)
                  }
              }
          }
          .padding()
          .onAppear {
              viewModel.fetchCalorieData()
              viewModel.calculatedInfo()
          }
      }
    
}
