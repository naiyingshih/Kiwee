//
//  WidgeView.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import SwiftUI
import Charts

enum TimeRange: String, CaseIterable, Identifiable {
    case last7Days = "7天"
    case last30Days = "30天"
    
    var id: String { self.rawValue }
}

struct NutrientsChartView: View {
    
    @StateObject var viewModel = ChartsViewModel()
    
    @State private var selectedTimeRange: TimeRange = .last7Days
    
    var body: some View {
        VStack {
            // Title
            Text("營養成分報告")
                .font(.title2)
                .bold()
            
            // Picker
              Picker("Select Time Range", selection: $selectedTimeRange) {
                  ForEach(TimeRange.allCases) { range in
                      Text(range.rawValue).tag(range)
                  }
              }
              .pickerStyle(SegmentedPickerStyle())
              .padding()
              .onChange(of: selectedTimeRange, initial: true, { _, newValue in
                  switch newValue {
                  case .last7Days:
                      viewModel.fetchNutrientData(day: 7)
                  case .last30Days:
                      viewModel.fetchNutrientData(day: 30)
                  }
              })
            
            // Reports
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 0) {
                    // Container for the Pie Chart
                    VStack {
                        Text("甜甜圈圖")
                            .font(.headline)
                        HStack {
                            Spacer()
                            
                            Chart(viewModel.nutrientData, id: \.label) { element in
                                SectorMark(
                                    angle: .value("攝取量", element.amount),
                                    innerRadius: .ratio(0.618), 
                                    angularInset: 1.5
                                )
                                .cornerRadius(5)
                                .foregroundStyle(by: .value("成分", element.label))
                                .annotation(position: .overlay) {
                                    let totalAmount = viewModel.nutrientData.reduce(0, { $0 + $1.amount })
                                    Text("\(element.amount / totalAmount * 100, specifier: "%.1f")%")
                                        .font(.caption)
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                        Spacer()
                    }.frame(width: 300, height: 230)
                    
                    // Container for the Bar Chart
                    VStack {
                        Text("直條圖")
                            .font(.headline)
                        HStack {
                            Spacer()
                            Chart(viewModel.nutrientData, id: \.label) { element in
                                BarMark(
                                    x: .value("成分", element.label),
                                    y: .value("攝取量", element.amount)
                                )
                                .foregroundStyle(by: .value("攝取量", element.label))
                                .annotation(position: .top, alignment: .center) {
                                    Text("\(element.amount, specifier: "%.1f")")
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(width: 300, height: 180)
                        }
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                }
                .frame(height: 240)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// struct IntakeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        NutrientsChartView()
//    }
// }
