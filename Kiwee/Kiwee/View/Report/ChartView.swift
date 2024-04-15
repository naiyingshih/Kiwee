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
            
            Text("Monthly Progress")
                .font(.title)
                .bold()
            
            HStack {
                VStack {
                    Toggle(isOn: $viewModel.graphType.isBarChart) {
                        Text("Bars")
                            .foregroundColor(Color.black)
                    }
                    .onChange(of: viewModel.graphType.isBarChart) { _, newValue in
                        if newValue {
                            viewModel.graphType.isPieChart = false
                            viewModel.graphType.isLineChart = false
                            viewModel.graphType.isProgressChart = false
                        }
                    }
                    Toggle(isOn: $viewModel.graphType.isPieChart) {
                        Text("Pie")
                            .foregroundColor(Color.black)
                    }
                    .onChange(of: viewModel.graphType.isPieChart) { _, newValue in
                        if newValue {
                            viewModel.graphType.isBarChart = false
                            viewModel.graphType.isLineChart = false
                            viewModel.graphType.isProgressChart = false
                        }
                    }
                }
                VStack {
                    Toggle(isOn: $viewModel.graphType.isProgressChart) {
                        Text("Progress")
                            .foregroundColor(Color.black)
                    }
                    .onChange(of: viewModel.graphType.isProgressChart) { _, newValue in
                        if newValue {
                            viewModel.graphType.isBarChart = false
                            viewModel.graphType.isLineChart = false
                            viewModel.graphType.isPieChart = false
                        }
                    }
                    Toggle(isOn: $viewModel.graphType.isLineChart) {
                        Text("Line")
                            .foregroundColor(Color.black)
                    }
                    .onChange(of: viewModel.graphType.isLineChart) { _, newValue in
                        if newValue {
                            viewModel.graphType.isBarChart = false
                            viewModel.graphType.isPieChart = false
                            viewModel.graphType.isProgressChart = false
                        }
                    }
                }
            }
            .padding()
            Chart(data, id: \.label) { element in
                if viewModel.graphType.isPieChart {
                    SectorMark(
                        angle: .value("Sales", element.amount)
                        , innerRadius: .ratio(0.618), angularInset: 1.5
                    )
                    .cornerRadius(5)
                    .foregroundStyle(by: .value("Name", element.label))
                }
                
                if viewModel.graphType.isBarChart {
                    BarMark(
                        x: .value("Month", element.label),
                        y: .value("Sales", element.amount)
                    )
                    .foregroundStyle(by: .value("Type", element.label))
                }
                if viewModel.graphType.isProgressChart {
                    BarMark(
                        x: .value("Sales", element.amount),
                        stacking: .normalized
                    )
                    .foregroundStyle(by: .value("Type", element.label))
                }
                
                if viewModel.graphType.isLineChart {
                    LineMark(
                        x: .value("Month", element.label),
                        y: .value("Sales", element.amount)
                    )
                    
                    PointMark(
                        x: .value("Month", element.label),
                        y: .value("Sales", element.amount)
                    )
                }
                
            }
            .frame(height: viewModel.graphType.isProgressChart ? 100: 380)
            .chartBackground { chartProxy in
                if viewModel.graphType.isPieChart {
                    GeometryReader { geometry in
                        let frame = geometry[chartProxy.plotFrame!]
                        VStack {
                            Text("Most Sold Style")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                            Text("March")
                                .font(.title2.bold())
                                .foregroundColor(.primary)
                        }
                        .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            .padding()
        
        }
        .padding()
    }
}
