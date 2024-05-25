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
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.hexStringToUIColor(hex: "004358")
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
    }
    
    let colorMapping: [String: Color] = [
        "碳水": Color(hex: "A1C181"),
        "蛋白": Color(hex: "FF928B"),
        "脂肪": Color(hex: "FCCA46"),
        "纖維": Color(hex: "CB997E")
    ]
    
    var body: some View {
        VStack {
            // Title
            Text("營養成分報告")
                .font(.title2)
                .bold()
                .padding(.top, 20)
            // Picker
            Picker("Select Time Range", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.all])
            .onChange(of: selectedTimeRange, initial: true, { _, newValue in
                switch newValue {
                case .last7Days:
                    viewModel.fetchNutrientData(forLastDays: 7)
                case .last30Days:
                    viewModel.fetchNutrientData(forLastDays: 30)
                }
            })
            
            // Reports with Page Control
            TabView {
                // First Page: Pie Chart
                VStack {
                    Chart(viewModel.nutrientData, id: \.label) { element in
                        SectorMark(
                            angle: .value("攝取量", element.amount),
                            innerRadius: .ratio(0.618),
                            angularInset: 1.5
                        )
                        .cornerRadius(5)
                        .foregroundStyle(colorMapping[element.label, default: .gray])
                        .annotation(position: .overlay) {
                            let totalAmount = viewModel.nutrientData.reduce(0, { $0 + $1.amount })
                            Text("\(element.amount / totalAmount * 100, specifier: "%.1f")%")
                                .font(.caption)
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(width: 280, height: 200, alignment: .top)
                    HStack {
                        ForEach(colorMapping.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack {
                                Circle()
                                    .fill(value)
                                    .frame(width: 8, height: 8)
                                Text(key)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.top)
                }
                .tag(0)
                
                // Second Page: Bar Chart
                VStack {
                    Chart(viewModel.nutrientData, id: \.label) { element in
                        BarMark(
                            x: .value("成分", element.label),
                            y: .value("攝取量", element.amount)
                        )
                        .foregroundStyle(colorMapping[element.label, default: .gray])
                        .annotation(position: .top, alignment: .center) {
                            Text("\(element.amount, specifier: "%.1f")")
                                .font(.caption)
                                .foregroundColor(.black)
                        }
                    }
                    .frame(width: 280, height: 200, alignment: .top)
                }
                .tag(1)
            }
            .tabViewStyle(PageTabViewStyle())
            .frame(height: 320)
            .padding(.horizontal)
        }
        .padding()
    }
}
