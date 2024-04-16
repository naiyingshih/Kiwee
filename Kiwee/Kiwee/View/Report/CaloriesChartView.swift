//
//  CaloriesChartView.swift
//  Kiwee
//
//  Created by NY on 2024/4/16.
//

import SwiftUI
import Charts

struct CaloriesChartView: View {
    
    var body: some View {
          VStack {
              Text("熱量報告")
                  .font(.title)
                  .bold()
                  .padding()
              
              Chart(caloriesData, id: \.label) { element in
                  LineMark(
                      x: .value("日期", element.label),
                      y: .value("熱量", element.amount)
                  )
                  .interpolationMethod(.catmullRom)
                  
                  PointMark(
                      x: .value("日期", element.label),
                      y: .value("熱量", element.amount)
                  )
                  .foregroundStyle(by: .value("熱量", element.amount))
                  
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
          }
          .padding()
      }
    
}
