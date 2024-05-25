//
//  IntegrationTest.swift
//  KiweeTests
//
//  Created by NY on 2024/5/19.
//

import XCTest
@testable import Kiwee

final class BMRIntegrationTests: XCTestCase {
    
    func testCalculateBMRWithValidData() {
        // Arrange
        let userData = createUserData(gender: 2, age: 18, goal: 0, activeness: 1, height: 168.0, initialWeight: 68.0, updatedWeight: 60.0)
        
        // Act
        let calculatedBMR = BMRUtility.calculateBMR(with: userData)

        // Assert
        XCTAssertEqual(calculatedBMR, 2445.3803, accuracy: 0.0001)
    }
    
}

// MARK: - Mock User Data
extension BMRIntegrationTests {
    func createUserData(
        id: String = "",
        name: String = "",
        gender: Int,
        age: Int,
        goal: Int,
        activeness: Int,
        height: Double,
        initialWeight: Double,
        updatedWeight: Double? = nil,
        goalWeight: Double = 52.0,
        achievementTime: Date = Date()
    ) -> UserData {
        return UserData(
            id: id,
            name: name,
            gender: gender,
            age: age,
            goal: goal,
            activeness: activeness,
            height: height,
            initialWeight: initialWeight,
            updatedWeight: updatedWeight,
            goalWeight: goalWeight,
            achievementTime: achievementTime
        )
    }
}
