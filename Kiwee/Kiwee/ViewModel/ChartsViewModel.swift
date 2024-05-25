//
//  ChartsViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import Foundation

class ChartsViewModel: ObservableObject {
    
    let firebaseManager = FirebaseManager.shared
    
    @Published var nutrientData: [PieChartData] = []
    @Published var caloriesData: [DataPoint] = []
    @Published var aggregatedCalorieDataPoints: [DataPoint] = []
    @Published var todayIntake: [PieChartData] = []
    @Published var userInputData: [DataPoint] = []
    @Published var calculatedBodyInfo: BodyInfo?
    
    init() {
        fetchNutrientData(forLastDays: Int())
        fetchCalorieData()
        getTodayIntake()
        fetchUserWeight()
        calculatedInfo()
    }
    
    // MARK: - fetching data for intake card
    func getTodayIntake() {
        let foodQuery = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: Date(), type: "food")
        let waterQuery = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: Date(), type: "water")
        
        var newData: [PieChartData] = []
        firebaseManager.fetchData(from: .intake, queryOption: foodQuery) { (result: Result<[Food], Error>) in
            switch result {
            case .success(let foods):
                let totalCalories = foods.reduce(0) { $0 + $1.totalCalories }
                newData.append(PieChartData(label: "已攝取量", amount: totalCalories))
                self.todayIntake = newData
            case .failure(let error):
                print("Error fetching food data: \(error)")
            }
        }
        
        firebaseManager.fetchData(from: .intake, queryOption: waterQuery) { (result: Result<[WaterCount], Error>) in
            switch result {
            case .success(let waterCounts):
                let totalWater = waterCounts.first?.waterCount ?? 0
                newData.append(PieChartData(label: "已飲水量", amount: Double(totalWater * 250)))
                self.todayIntake = newData
            case .failure(let error):
                print("Error fetching water data: \(error)")
            }
        }
    }
    
    // MARK: - fetching data for nutrients charts
    func fetchNutrientData(forLastDays days: Int) {
        let dates = generateDateRange(from: days)
        var allFoods: [Food] = []
        let dispatchGroup = DispatchGroup()
        
        for date in dates {
            dispatchGroup.enter()
            let queryOptions = firebaseManager.database.queryForUserIntake(userID: firebaseManager.userID ?? "", chosenDate: date, type: "food")
            firebaseManager.fetchData(from: .intake, queryOption: queryOptions) { (result: Result<[Food], Error>) in
                switch result {
                case .success(let foods):
                    allFoods.append(contentsOf: foods)
                case .failure(let error):
                    print("Error fetching foods: \(error)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.aggregateAndDisplayNutrientData(from: allFoods)
        }
    }
    
    private func generateDateRange(from daysAgo: Int) -> [Date] {
        var dates: [Date] = []
        for dayOffset in (0..<daysAgo).reversed() {
            if let date = Calendar.current.date(byAdding: .day, value: -dayOffset, to: Date()) {
                dates.append(date)
            }
        }
        return dates
    }
    
    private func aggregateAndDisplayNutrientData(from foods: [Food]) {
        var totalCarbohydrates: Double = 0
        var totalProtein: Double = 0
        var totalFat: Double = 0
        var totalFiber: Double = 0
        
        // Sum up nutrients
        for food in foods {
            totalCarbohydrates += food.nutrients.carbohydrates
            totalProtein += food.nutrients.protein
            totalFat += food.nutrients.fat
            totalFiber += food.nutrients.fiber
        }
        
        let aggregatedNutrientData = [
            PieChartData(label: "碳水", amount: totalCarbohydrates),
            PieChartData(label: "蛋白", amount: totalProtein),
            PieChartData(label: "脂肪", amount: totalFat),
            PieChartData(label: "纖維", amount: totalFiber)
        ]
        
        DispatchQueue.main.async {
            self.nutrientData = aggregatedNutrientData
        }
    }
    
    // MARK: - fetching data for total calorie chart
    func fetchCalorieData() {
        getOrderedDateData { [weak self] calories in
            DispatchQueue.main.async {
                self?.caloriesData = calories
                self?.aggregateCaloriesByDate()
            }
        }
    }
    
    private func getOrderedDateData(completion: @escaping ([DataPoint]) -> Void) {
        let query = firebaseManager.database.queryForTotalCalories(userID: firebaseManager.userID ?? "")
        
        firebaseManager.fetchData(from: .intake, queryOption: query) { [weak self] (result: Result<[Food], Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let documents):
                var dataPoints: [DataPoint] = []
                for document in documents {
                    let date = document.date
                    let calories = document.totalCalories
                    let data = DataPoint(date: date ?? Date(), dataPoint: calories)
                    dataPoints.append(data)
                }
                completion(dataPoints)
            case .failure(let error):
                print("Error fetching calories: \(error.localizedDescription)")
            }
        }
    }
    
    private func aggregateCaloriesByDate() {
        var aggregatedData = [Date: Double]()

        for dataPoint in caloriesData {
            // Normalize the date to remove time part if necessary
            let date = Calendar.current.startOfDay(for: dataPoint.date)
            if let existingTotal = aggregatedData[date] {
                aggregatedData[date] = existingTotal + dataPoint.dataPoint
            } else {
                aggregatedData[date] = dataPoint.dataPoint
            }
        }
        
        let sortedAggregatedData = aggregatedData.sorted { $0.key < $1.key }
        self.aggregatedCalorieDataPoints = sortedAggregatedData.map { DataPoint(date: $0.key, dataPoint: $0.value) }
    }

    // MARK: - fetching weight data
    func fetchUserWeight() {
        getUserWeight { [weak self] dataPoints in
            DispatchQueue.main.async {
                self?.userInputData = dataPoints
            }
        }
    }
    
    func getUserWeight(completion: @escaping ([DataPoint]) -> Void) {
        fetchUserDocumentID(userID: firebaseManager.userID ?? "") { [weak self] documentID in
            guard let documentID = documentID, let self = self else { return }
            let query = self.firebaseManager.database.queryForUserCurrentWeight(userID: self.firebaseManager.userID ?? "", userDocumentID: documentID)
            
            self.firebaseManager.fetchData(from: .users, queryOption: query) { [weak self] (result: Result<[WeightData], Error>) in
                guard self != nil else { return }
                switch result {
                case .success(let subDocuments):
                    var dataPoints: [DataPoint] = []
                    for subDocument in subDocuments {
                        let weight = subDocument.weight
                        let date = subDocument.date
                        let data = DataPoint(date: date ?? Date(), dataPoint: weight ?? 0.0)
                        dataPoints.append(data)
                    }
                    completion(dataPoints)
                case .failure(let error):
                    print("Error fetching calories: \(error.localizedDescription)")
                    completion([])
                }
            }
            
        }
    }
    
    func fetchUserDocumentID(userID: String, completion: @escaping (String?) -> Void) {
        firebaseManager.fetchDocumentID(UserID: firebaseManager.userID ?? "", collection: .users) { (result: Result<String, Error>) in
            switch result {
            case .success(let documentID):
                completion(documentID)
            case .failure(let error):
                print("Error fetching userID: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
    
    // MARK: - user info for calorie and weight charrts
    func calculatedInfo() {
        fetchUserData { [weak self] userData in
            let RDA = BMRUtility.calculateBMR(with: userData)
            let bodyInfo = BodyInfo(initWeight: userData.initialWeight,
                                    goalWeight: userData.goalWeight,
                                    RDA: RDA
            )
            DispatchQueue.main.async {
                self?.calculatedBodyInfo = bodyInfo
            }
        }
    }
    
    func fetchUserData(completion: @escaping (UserData) -> Void) {
        guard let userID = firebaseManager.userID else { return }
        let query = firebaseManager.database.queryByOneField(userID: userID, collection: .users, field: "id", fieldContent: userID)
        
        firebaseManager.fetchData(from: .users, queryOption: query) { [weak self] (result: Result<[UserData], Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let userdata):
                let userdata = userdata.first
                guard let userInfo = userdata else { return }
                completion(userInfo)
            case .failure(let error):
                print("Error fetching calories: \(error.localizedDescription)")
            }
        }
    }

}
