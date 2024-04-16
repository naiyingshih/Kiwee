//
//  WeightChartView.swift
//  Kiwee
//
//  Created by NY on 2024/4/16.
//

import SwiftUI
import Charts

struct WeightChartView: View {
    
    @StateObject var viewModel = ChartsViewModel()
    
    var body: some View {
          VStack {
              Text("體重報告")
                  .font(.title2)
                  .bold()
                  .padding()
              
              Chart(viewModel.weightData, id: \.label) { element in
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
//              .chartScrollableAxes(.horizontal)
//              .chartXVisibleDomain(length: 1800 * 24 * 30)
          }
          .padding()
      }
    
}
