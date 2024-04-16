//
//  WeightChartView.swift
//  Kiwee
//
//  Created by NY on 2024/4/16.
//

import SwiftUI
import Charts

struct WeightChartView: View {
    
    var body: some View {
          VStack {
              Text("體重報告")
                  .font(.title)
                  .bold()
                  .padding()
              
              Chart(weightData, id: \.label) { element in
                  LineMark(
                      x: .value("日期", element.label),
                      y: .value("體重", element.amount)
                  )
                  .interpolationMethod(.catmullRom)
                  
                  PointMark(
                      x: .value("日期", element.label),
                      y: .value("體重", element.amount)
                  )
                  .foregroundStyle(by: .value("體重", element.amount))
              }
              .frame(height: 200)
          }
          .padding()
      }
    
}