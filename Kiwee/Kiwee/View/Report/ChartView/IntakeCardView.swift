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
                .foregroundColor(Color(hex: "004358"))
                .padding([.leading, .bottom])
            HStack {
                Spacer()
                PieChartView()
                    .frame(width: 180, height: 180)
                Spacer()
                VStack {
                    Text("已攝取熱量\n\(caloriesIntake, specifier: "%.0f") kcal")
                        .padding([.leading, .bottom])
                    Text("已飲水量\n\(waterIntake, specifier: "%.0f") ml")
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "BEDB39"))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct PieChartView: View {
    
    @StateObject var viewModel = ChartsViewModel()
    
    var caloriesIntake: Double {
        viewModel.todayIntake.first(where: { $0.label == "已攝取量" })?.amount ?? 0
    }
    
    var body: some View {
        Chart(viewModel.todayIntake, id: \.label) { item in
            if item.label == "已攝取量" {
                let percentage = item.amount / 2500 * 100
                SectorMark(
                    angle: .value("Value", percentage),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .opacity(0.3)
                .cornerRadius(5)
                .foregroundStyle(Color(hex: "fb8500"))
                .annotation(position: .overlay) {
                    Text("\(percentage, specifier: "%.1f")%")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            } else {
                // Calculate the remaining percentage
                let remainingAmount = (viewModel.todayIntake.first(where: { $0.label == "已攝取量" })?.amount ?? 0) / 2500 * 100
                let remainingPercentage = 100 - remainingAmount
                SectorMark(
                    angle: .value("Value", remainingPercentage),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .opacity(1.0)
                .cornerRadius(5)
                .foregroundStyle(Color(hex: "fb8500"))
                .annotation(position: .overlay) {
                    Text("\(remainingPercentage, specifier: "%.1f")%")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
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
                        .foregroundColor(Color(hex: "004358"))
                    Text("/\(RDA ?? 0, specifier: "%.0f") kcal")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .position(x: frame.midX, y: frame.midY)
            }
        }
        .frame(height: 200)
    }
}

// struct IntakeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        IntakeCardView()
//    }
// }
