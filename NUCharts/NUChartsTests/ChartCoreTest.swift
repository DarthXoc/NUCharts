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
    
    // MARK: - chartCore.calculateInterval
    
    /// Test from 0 to positive 10
    func test_CalculateInterval_0_to_10() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 10, minValue: 0);
        
        // The expected value
        let floatExpected: CGFloat = 1;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Test from 0 to positive 25
    func test_CalculateInterval_0_to_25() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 25, minValue: 0);
        
        // The expected value
        let floatExpected: CGFloat = 5;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Test from 0 to positive 50
    func test_CalculateInterval_0_to_50() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 50, minValue: 0);
        
        // The expected value
        let floatExpected: CGFloat = 10;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Test from 0 to positive 100
    func test_CalculateInterval_0_to_100() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 100, minValue: 0);
        
        // The expected value
        let floatExpected: CGFloat = 25;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Test from 0 to positive 250
    func test_CalculateInterval_0_to_250() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 250, minValue: 0);
        
        // The expected value
        let floatExpected: CGFloat = 50;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Test from 0 to positive 500
    func test_CalculateInterval_0_to_500() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 500, minValue: 0);
        
        // The expected value
        let floatExpected: CGFloat = 100;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Test from 0 to positive 1000
    func test_CalculateInterval_0_to_1000() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 1000, minValue: 0);
        
        // The expected value
        let floatExpected: CGFloat = 250;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
    
    /// Test from negative 100 to positive 100
    func test_CalculateInterval_100_100() throws {
        // Execute the test
        let floatResponse: CGFloat = ChartCore.calculateInterval(maxValue: 100, minValue: -100);
        
        // The expected value
        let floatExpected: CGFloat = 50;
        
        // Return the test result
        XCTAssert(floatResponse == floatExpected, "Expected \(floatExpected), got \(floatResponse)");
    }
}
