//
//  ChartCoreTests.swift
//  NUChartsTests
//
//  Created by Jason Cox on 6/16/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

@testable import NUCharts;
import XCTest

class ChartCoreTests: XCTestCase {
    
    /// Tests `blendColors` in ChartCore
    func test_blendColors() throws {
        // Execute the test
        let colorResponse: UIColor = ChartCore.blendColors(colors: [.white, .black]);
        
        // The expected value
        let colorExpected: UIColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0);
        
        // Return the test result
        XCTAssert(colorResponse == colorExpected, "Expected \(colorExpected), got \(colorResponse)");
    }
    
    /// Tests `calculateIncriment` in ChartCore
    func test_calculateIncriment() throws {
        // Create an array of mock values
        let arrayValues: [Double]? = Mocks.arrayOfValues_100_50_0_50_100();
        
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateIncriment(in: Mocks.collectionView(),
                                                                  with: arrayValues);
        
        // The expected value
        let floatExpected: CGFloat = 25;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Tests `calculateInterval` in ChartCore
    func test_calculateInterval() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 1000, minValue: 0);
        
        // The expected value
        let floatExpected: CGFloat = 250;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
        
    /// Tests `calculatePointLocationY` in ChartCore
    func test_calculatePointLocationY() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculatePointLocationY(in: Mocks.collectionView(),
                                                                       with: Mocks.arrayOfValues_100_50_0_50_100(),
                                                                       at: IndexPath(row: 3, section: 0));
        
        // The expected value
        let floatExpected: CGFloat = 25.0;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
        
    /// Tests `calculateRange:arrayPayload` in ChartCore
    func test_calculateRangeArray() throws {
        // Execute the test
        let doubleResponse: Double = ChartCore.calculateRange(for: Mocks.arrayOfValues_100_50_0_50_100());
        
        // The expected value
        let doubleExpected: Double = 200.0;
        
        // Return the test result
        XCTAssert(doubleResponse == doubleExpected, "Expected \(doubleExpected), got \(doubleResponse)");
    }
        
    /// Tests `calculateRange:maxValue:minValue` in ChartCore
    func test_calculateRangeValues() throws {
        // Execute the test
        let doubleResponse: Double = ChartCore.calculateRange(maxValue: 100, minValue: -100);
        
        // The expected value
        let doubleExpected: Double = 200.0;
        
        // Return the test result
        XCTAssert(doubleResponse == doubleExpected, "Expected \(doubleExpected), got \(doubleResponse)");
    }
    
    /// Tests `calculateZeroAxisLocation` in ChartCore
    func test_calculateZeroAxisLocation() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateZeroAxisLocation(for: Mocks.collectionView(),
                                                                         with: Mocks.arrayOfValues_100_50_0_50_100());
        
        // The expected value
        let floatExpected: CGFloat = 50.0;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Tests `payloadMax` in ChartCore
    func test_payloadMax() throws {
        // Execute the test
        let doubleResponse: Double = ChartCore.payloadMax(for: Mocks.arrayOfValues_100_50_0_50_100())
        
        // The expected value
        let doubleExpected: Double = 100.0;
        
        // Return the test result
        XCTAssert(doubleResponse == doubleExpected, "Expected \(doubleExpected), got \(doubleResponse)");
    }
    
    /// Tests `payloadMin` in ChartCore
    func test_payloadMin() throws {
        // Execute the test
        let doubleResponse: Double = ChartCore.payloadMin(for: Mocks.arrayOfValues_100_50_0_50_100())
        
        // The expected value
        let doubleExpected: Double = -100.0;
        
        // Return the test result
        XCTAssert(doubleResponse == doubleExpected, "Expected \(doubleExpected), got \(doubleResponse)");
    }
}
