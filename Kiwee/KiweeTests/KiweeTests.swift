//
//  KiweeTests.swift
//  KiweeTests
//
//  Created by NY on 2024/5/18.
//

import XCTest
@testable import Kiwee

final class BMRUtilityTests: XCTestCase {

    func testCalculateBMRForGenderMale() {
        // Act
        let bmrForMale = BMRUtility.calculateBMRForGender(1, weight: 80.0, height: 180.0, age: 18)

        // Assert
        XCTAssertEqual(bmrForMale, 1921.756, accuracy: 0.001)
    }

    func testCalculateBMRForGenderFemale() {
        // Act
        let bmrForFemale = BMRUtility.calculateBMRForGender(2, weight: 55.0, height: 155.0, age: 36)

        // Assert
        XCTAssertEqual(bmrForFemale, 1280.488, accuracy: 0.001)
    }

    func testAdjustBMRForActivityLevel() {
        // Arrange
        let bmr = 1800.0

        // Act and Assert
        XCTAssertEqual(BMRUtility.adjustBMRForActivityLevel(bmr, activeness: 4), 2160.0, accuracy: 0.001)
        XCTAssertEqual(BMRUtility.adjustBMRForActivityLevel(bmr, activeness: 3), 2790.0, accuracy: 0.001)
        XCTAssertEqual(BMRUtility.adjustBMRForActivityLevel(bmr, activeness: 2), 3105.0, accuracy: 0.001)
        XCTAssertEqual(BMRUtility.adjustBMRForActivityLevel(bmr, activeness: 1), 3420.0, accuracy: 0.001)
        XCTAssertEqual(BMRUtility.adjustBMRForActivityLevel(bmr, activeness: 0), 1800.0, accuracy: 0.001)
    }

    func testAdjustBMRForGoal() {
        // Arrange
        let bmr = 1800.0

        // Act and Assert
        XCTAssertEqual(BMRUtility.adjustBMRForGoal(bmr, goal: 0), 1500.0, accuracy: 0.001)
        XCTAssertEqual(BMRUtility.adjustBMRForGoal(bmr, goal: 1), 2100.0, accuracy: 0.001)
        XCTAssertEqual(BMRUtility.adjustBMRForGoal(bmr, goal: 2), 1800.0, accuracy: 0.001)
    }

}
