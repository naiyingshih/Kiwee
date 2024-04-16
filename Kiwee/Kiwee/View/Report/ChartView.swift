//
//  WidgeView.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import SwiftUI
import Charts

struct ContentView: View {
    
    @StateObject var viewModel = ChartsViewModel()
    
    var body: some View {
        VStack {
            Text("營養成分報告")
                .font(.title)
                .bold()
            
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 0) {
                    // Container for the Pie Chart
                    VStack {
                        Spacer()
                        Text("甜甜圈圖")
                            .font(.headline)
                        HStack {
                            Spacer()
                            Chart(data, id: \.label) { element in
                                SectorMark(
                                    angle: .value("攝取量", element.amount),
                                    innerRadius: .ratio(0.618), angularInset: 1.5
                                )
                                .cornerRadius(5)
                                .foregroundStyle(by: .value("成分", element.label))
                            }
                        }
                        Spacer()
                    }.frame(width: 300, height: 200)
                    
                    // Container for the Bar Chart
                    VStack {
                        Spacer()
                        Text("直條圖")
                            .font(.headline)
                        HStack {
                            Spacer()
                            Chart(data, id: \.label) { element in
                                BarMark(
                                    x: .value("成分", element.label),
                                    y: .value("攝取量", element.amount)
                                )
                                .foregroundStyle(by: .value("攝取量", element.label))
                            }
                            .frame(width: 300, height: 200)
                        }
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width)
                }
                .frame(height: 250)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
