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
              
              Chart(viewModel.userInputData, id: \.date) { element in
                  LineMark(
                      x: .value("日期", element.date),
                      y: .value("體重", element.calories)
                  )
                  .interpolationMethod(.catmullRom)
                  
                  PointMark(
                      x: .value("日期", element.date),
                      y: .value("體重", element.calories)
                  )
                  .foregroundStyle(by: .value("體重", element.calories))
                  
                  RuleMark(y: .value("體重", 65))
                      .foregroundStyle(.gray)
                      .annotation(position: .top,
                                  alignment: .topLeading) {
                          Text("初始體重: 65 kcal")
                              .font(.system(size: 12))
                              .foregroundColor(.gray)
                      }
              }
              .frame(height: 200)
              .chartScrollableAxes(.horizontal)
              .chartXVisibleDomain(length: 365000 * 2)
          }
          .padding()
      }
    
}

// struct IntakeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeightChartView()
//    }
// }
