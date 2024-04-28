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
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.hexStringToUIColor(hex: "FFE11A")
        UIPageControl.appearance().pageIndicatorTintColor = .lightGray
    }
    
    let colorMapping: [String: Color] = [
        "碳水": Color(red: 167/255, green: 201/255, blue: 87/255),
        "蛋白": Color(red: 255/255, green: 146/255, blue: 139/255),
        "脂肪": Color(red: 252/255, green: 202/255, blue: 70/255),
        "纖維": Color(red: 203/255, green: 153/255, blue: 126/255)
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
            .padding(.top, 20)
            .onChange(of: selectedTimeRange, initial: true, { _, newValue in
                switch newValue {
                case .last7Days:
                    viewModel.fetchNutrientData(day: 7)
                case .last30Days:
                    viewModel.fetchNutrientData(day: 30)
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

// struct IntakeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        NutrientsChartView()
//    }
// }
