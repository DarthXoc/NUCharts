//
//  PieChartViewController.swift
//  Demo
//
//  Created by Jason Cox on 6/11/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

import NUCharts;
import UIKit;

class PieChartViewController: UIViewController, PieChartDataSource, PieChartDelegate {
    
    // MARK: - IBOutlets
    
    @IBOutlet var pieChart: PieChart?;
    @IBOutlet var buttonSubmit: UIButton_Flat?;
    @IBOutlet var textFieldDataPoints: UITextField_Icons?;
    @IBOutlet var textFieldMaxValue: UITextField_Icons?;
    @IBOutlet var textFieldMinValue: UITextField_Icons?;
    @IBOutlet var segmentedControlPieType: UISegmentedControl?;
    @IBOutlet var segmentedControlValueType: UISegmentedControl?;
    
    // MARK: - Variables
    
    private var arrayPayload: [Double]?;
    
    // MARK: - General Functions

    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Configure the bar chart
        pieChart?.dataSource = self;
        pieChart?.delegate = self;
        
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
        
        // Sort the test payload
        arrayPayload?.sort(by: { $0 > $1 });
        
        // Set the type of pie chart that will be drawn
        pieChart?.settings.pieType = segmentedControlPieType?.selectedSegmentIndex == 0 ? .half : .full;
        
        // Draw the chart
        pieChart?.draw();
    }
    
    @IBAction func segmentedControlValueType_ValueChanged(_ sender: UISegmentedControl) {
        // Validate user input
        self.validateUserInput();
    }
    
    @IBAction func textField_EditingChanged(_ sender: UITextField) {
        // Validate user input
        self.validateUserInput();
    }
    
    // MARK: - Pie Chart
    
    func pieChart(_ pieChart: PieChart, didSelectItemAt index: Int?) {
        // Check to make sure that index is not nil
        guard let intIndex: Int = index else {
            return
        }
        
        // Setup an alert controller
        let alertController: UIAlertController = UIAlertController(title: "Tooltip Tapped", message: "Index: \(intIndex)\rValue: \(arrayPayload?[intIndex] ?? 0)", preferredStyle: .alert);
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil);
    };
    
    func pieChart(_ pieChart: PieChart, valueForItemAt index: Int) -> Double {
        return arrayPayload?[index] ?? .zero;
    }
    
    func numberOfItems(in pieChart: PieChart) -> Int {
        return arrayPayload?.count ?? .zero;
    }
        
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

