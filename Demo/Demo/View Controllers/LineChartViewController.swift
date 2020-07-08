//
//  LineChartViewController.swift
//  Demo
//
//  Created by Jason Cox on 6/11/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

import NUCharts;
import UIKit;

class LineChartViewController: UIViewController, LineChartDataSource, LineChartDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet var lineChart: LineChart?;
    @IBOutlet var buttonSubmit: UIButton_Flat?;
    @IBOutlet var textFieldDataPoints: UITextField_Icons?;
    @IBOutlet var textFieldMaxValue: UITextField_Icons?;
    @IBOutlet var textFieldMinValue: UITextField_Icons?;
    @IBOutlet var segmentedControlValueType: UISegmentedControl?;
    
    // MARK: - Variables
    
    private var arrayPayload: [Double]?;
    
    // MARK: - General Functions

    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Configure the line chart
        lineChart?.dataSource = self;
        lineChart?.delegate = self;
        
        // Create the chart
        self.createChart_Tap(buttonSubmit);
    }
    
    // MARK: - IBActions
    
    @IBAction func createChart_Tap(_ sender: UIButton?) {
        // Generate the test payload
        arrayPayload = ChartCore.generateTestPayload(numberOfDataPoints: Int(textFieldDataPoints!.text!) ?? 0,
                                                     maxValue: Double(textFieldMaxValue!.text!) ?? 0,
                                                     minValue: Double(textFieldMinValue!.text!) ?? 0,
                                                     valueType: segmentedControlValueType?.selectedSegmentIndex == 0 ? .integer : .double);
        
        // Draw the chart
        lineChart?.draw();
    }
    
    @IBAction func segmentedControlValueType_ValueChanged(_ sender: UISegmentedControl) {
        // Validate user input
        self.validateUserInput();
    }
    
    @IBAction func textField_EditingChanged(_ sender: UITextField) {
        // Validate user input
        self.validateUserInput();
    }
    
    // MARK: - Line Chart
    
    func lineChart(_ lineChart: LineChart, didSelectItemAt index: Int) {
        // Setup an alert controller
        let alertController: UIAlertController = UIAlertController(title: "Tooltip Tapped", message: "Index: \(index)\rValue: \(arrayPayload?[index] ?? 0)", preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil);
    };
    
//    func lineChart(_ lineChart: LineChart, axisXGridLineActiveForItemAt index: Int) -> Bool? {
//        return false;
//    }

//    func lineChart(_ lineChart: LineChart, axisXGridLineColorForItemAt index: Int) -> UIColor? {
//        return .systemBlue;
//    };

//    func lineChart(_ lineChart: LineChart, axisXGridLineStyleForItemAt index: Int) -> ChartCore.LineStyle? {
//        return .dotted;
//    };

//    func lineChart(_ lineChart: LineChart, axisXGridLineWidthForItemAt index: Int) -> CGFloat? {
//        return 3.0;
//    };
    
//    func lineChart(_ lineChart: LineChart, sectionTitleForItemAt index: Int) -> String? {
//        return "Section";
//    };
    
//    func lineChart(_ lineChart: LineChart, sectionTitleColorForItemAt index: Int) -> UIColor? {
//        return .systemRed;
//    };
    
//    func lineChart(_ lineChart: LineChart, sectionTitleFontForItemAt index: Int) -> UIFont {
//        return UIFont.preferredFont(forTextStyle: .body);
//    };
    
//    func lineChart(_ lineChart: LineChart, tooltipTitleForItemAt index: Int) -> String {
//        return String("Item \(index)");
//    };
    
//    func lineChart(_ lineChart: LineChart, valueForItemAt index: Int) -> Double {
//        return arrayPayload?[index] ?? 0;
//    };
    
//    func numberOfItems(in lineChart: LineChart) -> Int {
//        return arrayPayload?.count ?? 0;
//    }
    
    func values(for lineChart: LineChart) -> [Double] {
        return arrayPayload ?? [];
    };
    
    // MARK: - Validation
    
    /// Validates user input
    private func validateUserInput() {
        // Validate the text fields
        let boolDataPointsValid: Bool = Int(textFieldDataPoints?.text ?? "") != nil;
        let boolMaxValueValid: Bool = segmentedControlValueType?.selectedSegmentIndex == 0 ? Int(textFieldMaxValue?.text ?? "") != nil : Double(textFieldMaxValue?.text ?? "") != nil;
        let boolMinValueValid: Bool = segmentedControlValueType?.selectedSegmentIndex == 0 ? Int(textFieldMinValue?.text ?? "") != nil : Double(textFieldMinValue?.text ?? "") != nil;
        
        // Check to see if validation succeeded
        if (boolDataPointsValid) {
            // Configure the text field to indicate that validation succeeded
            textFieldDataPoints?.leadingIcon = nil;
        } else {
            // Configure the text field to indicate that validation failed
            textFieldDataPoints?.leadingColor = .systemRed;
            textFieldDataPoints?.leadingIcon = UIImage(systemName: "exclamationmark.triangle.fill");
            textFieldDataPoints?.leadingTapAction = {
                // Configure a UIAlertController
                let alertController: UIAlertController = UIAlertController(title: "Validation", message: "Please enter a valid Int value.", preferredStyle: .alert);
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
                
                // Present the alert
                self.present(alertController, animated: true, completion: nil);
            }
        }
        
        // Check to see if validation succeeded
        if (boolMaxValueValid) {
            // Configure the text field to indicate that validation succeeded
            textFieldMaxValue?.leadingIcon = nil;
        } else {
            // Configure the text field to indicate that validation failed
            textFieldMaxValue?.leadingColor = .systemRed;
            textFieldMaxValue?.leadingIcon = UIImage(systemName: "exclamationmark.triangle.fill");
            textFieldMaxValue?.leadingTapAction = {
                // Configure a UIAlertController
                let alertController: UIAlertController = UIAlertController(title: "Validation", message: "Please enter a valid \(self.segmentedControlValueType?.selectedSegmentIndex == 0 ? "Int" : "Double" ) value.", preferredStyle: .alert);
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
                
                // Present the alert
                self.present(alertController, animated: true, completion: nil);
            }
        }
        
        // Check to see if validation succeeded
        if (boolMinValueValid) {
            // Configure the text field to indicate that validation succeeded
            textFieldMinValue?.leadingIcon = nil;
        } else {
            // Configure the text field to indicate that validation failed
            textFieldMinValue?.leadingColor = .systemRed;
            textFieldMinValue?.leadingIcon = UIImage(systemName: "exclamationmark.triangle.fill");
            textFieldMinValue?.leadingTapAction = {
                // Configure a UIAlertController
                let alertController: UIAlertController = UIAlertController(title: "Validation", message: "Please enter a valid \(self.segmentedControlValueType?.selectedSegmentIndex == 0 ? "Int" : "Double" ) value.", preferredStyle: .alert);
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
                
                // Present the alert
                self.present(alertController, animated: true, completion: nil);
            }
        }
        
        // Enable or disable the button
        buttonSubmit?.isEnabled = boolDataPointsValid && boolMaxValueValid && boolMinValueValid;
    }
}
