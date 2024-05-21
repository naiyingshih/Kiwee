//
//  CollectionReusableView.swift
//  Kiwee
//
//  Created by NY on 2024/4/17.
//

import SwiftUI
import Charts

struct IntakeCardView: View {
    
    @StateObject var viewModel = ChartsViewModel()
    
    // Computed properties to dynamically fetch the required data
     var caloriesIntake: Double {
         viewModel.todayIntake.first(where: { $0.label == "已攝取量" })?.amount ?? 0
     }
     
     var waterIntake: Double {
         viewModel.todayIntake.first(where: { $0.label == "已飲水量" })?.amount ?? 0
     }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("今日剩餘攝取量")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding([.leading, .bottom])
                .shadow(color: .black, radius: 1, x: 1, y: 1)
            HStack {
                Spacer()
                PieChartView()
                    .frame(width: 180, height: 180)
                Spacer()
                VStack {
                    Text("已攝取熱量\n\(caloriesIntake, specifier: "%.0f") kcal")
                        .padding([.leading, .bottom])
                        .foregroundColor(.white)
                    Text("已飲水量\n\(waterIntake, specifier: "%.0f") ml")
                        .foregroundColor(.white)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "004358"))
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            viewModel.getTodayIntake()
        }
    }
}

struct PieChartView: View {
    
    @StateObject var viewModel = ChartsViewModel()
    
    var caloriesIntake: Double {
        viewModel.todayIntake.first(where: { $0.label == "已攝取量" })?.amount ?? 0
    }
    
    var RDA: Double {
        viewModel.calculatedBodyInfo?.RDA ?? 0
    }
    
    var body: some View {
        Chart(viewModel.todayIntake, id: \.label) { item in
            if item.label == "已攝取量" {
                let percentage = item.amount / RDA * 100
                SectorMark(
                    angle: .value("Value", percentage),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .opacity(0.3)
                .cornerRadius(5)
                .foregroundStyle(Color(hex: "FFCA28"))
                .annotation(position: .overlay) {
                    Text("\(percentage, specifier: "%.1f")%")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                }.zIndex(1)
            } else {
                // Calculate the remaining percentage
                let remainingAmount = (viewModel.todayIntake.first(where: { $0.label == "已攝取量" })?.amount ?? 0) / RDA * 100
                let remainingPercentage = 100 - remainingAmount
                SectorMark(
                    angle: .value("Value", remainingPercentage),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .opacity(1.0)
                .cornerRadius(5)
                .foregroundStyle(Color(hex: "FFCA28"))
                .annotation(position: .overlay) {
                    Text("\(remainingPercentage, specifier: "%.1f")%")
                        .font(.headline)
                        .foregroundStyle(remainingPercentage < 0 ? .red : .white)
                        .shadow(color: .black, radius: 1, x: 1, y: 1)
                }.zIndex(0)
            }
        }
        .chartBackground { proxy in
            GeometryReader { geometry in
                let frame = geometry[proxy.plotFrame!]
                VStack {
                    let RDA = viewModel.calculatedBodyInfo?.RDA
                    Text("\((RDA ?? 0) - caloriesIntake, specifier: "%.0f") kcal")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                        .foregroundColor((RDA ?? 0) - caloriesIntake < 0 ? .red : Color(hex: "FFCA28"))
                    Text("/\(RDA ?? 0, specifier: "%.0f") kcal")
                        .font(.callout)
                        .foregroundColor(Color(hex: "CCCCCC"))
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
        .frame(height: 200)
        .onAppear {
            viewModel.getTodayIntake()
        }
    }
}

// struct IntakeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        IntakeCardView()
//    }
// }
