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
        
        let initWeight = viewModel.calculatedBodyInfo?.initWeight ?? 0
        let goalWeight = viewModel.calculatedBodyInfo?.goalWeight ?? 0
        
        VStack {
            Text("體重報告")
                .font(.title2)
                .bold()
                .padding()
            
            Chart(viewModel.userInputData, id: \.date) { element in
                LineMark(
                    x: .value("日期", element.date),
                    y: .value("體重", element.dataPoint)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(Color(hex: "fb8500"))
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("日期", element.date),
                    y: .value("體重", element.dataPoint)
                )
                .foregroundStyle(Color(hex: "fb8500"))
                //                  .foregroundStyle(by: .value("體重", element.dataPoint))
                .annotation(position: .bottomTrailing, alignment: .center) {
                    Text("\(element.dataPoint, specifier: "%.0f")")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                
//                let initWeight = viewModel.calculatedBodyInfo?.initWeight
                RuleMark(y: .value("體重", initWeight))
                    .foregroundStyle(.gray)
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .annotation(position: .top,
                                alignment: .topLeading) {
                        Text("初始體重: \(initWeight, specifier: "%.0f")")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                // Add your second RuleMark here
//                let goalWeight = viewModel.calculatedBodyInfo?.goalWeight
                RuleMark(y: .value("體重", goalWeight))
                    .foregroundStyle(.yellow)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .annotation(position: .top,
                                alignment: .topTrailing) {
                        Text("目標體重: \(goalWeight, specifier: "%.0f")")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
            }
            .padding([.all])
            .frame(height: 200)
            .chartScrollableAxes(.horizontal)
            .chartXVisibleDomain(length: 365000)
            .chartXAxis {
                AxisMarks(preset: .automatic, position: .bottom)
            }
            .chartYScale(domain: initWeight > goalWeight ?
                         goalWeight - 5...initWeight + 5 :
                            initWeight - 5...goalWeight + 5
            )
        }
        .padding()
    }
    
}

// struct IntakeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        WeightChartView()
//    }
// }
