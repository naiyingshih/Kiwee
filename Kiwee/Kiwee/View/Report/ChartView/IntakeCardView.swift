//
//  CollectionReusableView.swift
//  Kiwee
//
//  Created by NY on 2024/4/17.
//

import SwiftUI
import Charts

struct IntakeCardView: View {
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("今日剩餘攝取量")
                .font(.title2)
                .fontWeight(.bold)
                .padding([.leading, .bottom])
            HStack {
                Spacer()
                PieChartView()
                    .frame(width: 150, height: 150)
                Spacer()
                VStack {
                    Text("已攝取熱量\n300 kcal")
                        .padding([.leading, .bottom])
                    Text("已飲水量\n500 ml")
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.yellow)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct PieChartView: View {
    
    @StateObject var viewModel = ChartsViewModel()
    
    var body: some View {
        Chart(viewModel.data, id: \.label) { item in
            SectorMark(
                angle: .value("Value", item.amount),
                innerRadius: .ratio(0.618),
                angularInset: 1.5
            )
            .opacity(item.label == "已攝取量" ? 0.2 : 1.0)
            .cornerRadius(5)
            .annotation(position: .overlay) {
                Text("\(item.amount / 100, specifier: "%.1f")%")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .chartBackground { proxy in
            GeometryReader { geometry in
                let frame = geometry[proxy.plotFrame!]
                VStack {
                    Text("700 kcal")
                        .font(.title3.bold())
                        .foregroundStyle(.primary)
                    Text("/1000 kcal")
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
