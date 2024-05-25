//
//  AddFoodViewModelTests.swift
//  KiweeTests
//
//  Created by NY on 2024/5/19.
//

import XCTest
@testable import Kiwee

class AddFoodViewModelTests: XCTestCase {

    var addFoodVM: AddFoodViewModel!

    override func setUp() {
        super.setUp()
        addFoodVM = AddFoodViewModel()
    }

    override func tearDown() {
        addFoodVM = nil
        super.tearDown()
    }

    func testCalculateIntakeData() {
        // Given
        let food = Food(
            id: "testID",
            documentID: "testDocumentID",
            name: "Test Food",
            totalCalories: 100,
            nutrients: Food.Nutrient(carbohydrates: 20, protein: 10, fat: 5, fiber: 2),
            image: "testImage",
            quantity: 100,
            section: 1,
            date: Date()
        )
        let quantity = 150.0
        
        // When
        let result = addFoodVM.calculateIntakeData(for: food, quantity: quantity)

        // Then
        guard let totalCalories = result?.totalCalories else { return }
        guard let carbohydrates = result?.nutrients.carbohydrates else { return }
        guard let protein = result?.nutrients.protein else { return }
        guard let nutrients = result?.nutrients.fat else { return }
        guard let fiber = result?.nutrients.fiber else { return }
        
        XCTAssertNotNil(result, "Result should not be nil")
        XCTAssertEqual(totalCalories, 150.0, accuracy: 0.1, "Calculated total calories are incorrect")
        XCTAssertEqual(carbohydrates, 30.0, accuracy: 0.1, "Calculated carbohydrates are incorrect")
        XCTAssertEqual(protein, 15.0, accuracy: 0.1, "Calculated protein is incorrect")
        XCTAssertEqual(nutrients, 7.5, accuracy: 0.1, "Calculated fat is incorrect")
        XCTAssertEqual(fiber, 3.0, accuracy: 0.1, "Calculated fiber is incorrect")
    }
}
