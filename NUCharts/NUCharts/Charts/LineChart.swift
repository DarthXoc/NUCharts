//
//  LineChart.swift
//  NUCharts
//
//  Created by Jason Cox on 6/11/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

import UIKit

public protocol LineChartDataSource: class {
    /// Asks the delegate whether the X-Axis grid line should be shown
    func lineChart(_ lineChart: LineChart, axisXGridLineActiveForItemAt index: Int) -> Bool?;
    
    /// Asks the delegate what the color of the X-Axis grid line should be
    func lineChart(_ lineChart: LineChart, axisXGridLineColorForItemAt index: Int) -> UIColor?;
    
    /// Asks the delegate what the line style of the X-Axis grid line should be
    func lineChart(_ lineChart: LineChart, axisXGridLineStyleForItemAt index: Int) -> ChartCore.LineStyle?;
    
    /// Asks the delegate what the width of the X-Axis grid line should be
    func lineChart(_ lineChart: LineChart, axisXGridLineWidthForItemAt index: Int) -> CGFloat?;
    
    /// Asks the delegate for the title of this section
    func lineChart(_ lineChart: LineChart, sectionTitleForItemAt index: Int) -> String?;
    
    /// Asks the delegate what the color of the section title should be
    func lineChart(_ lineChart: LineChart, sectionTitleColorForItemAt index: Int) -> UIColor?;
    
    /// Asks the delegate what the font of the section title should be
    func lineChart(_ lineChart: LineChart, sectionTitleFontForItemAt index: Int) -> UIFont;
    
    /// Asks the delegate what the title for the tooltip should be
    func lineChart(_ lineChart: LineChart, tooltipTitleForItemAt index: Int) -> String;
    
    /// Asks the delegate what the value for the tooltip should be
    func lineChart(_ lineChart: LineChart, tooltipValueForItemAt index: Int) -> String;
    
    /// Asks the delegate for the value at the specified index
    func lineChart(_ lineChart: LineChart, valueForItemAt index: Int) -> Double
    
    /// Asks the delegate for the max value of the chart
    func maxValue(in lineChart: LineChart) -> Double;
    
    /// Asks the delegate for the min value of the chart
    func minValue(in lineChart: LineChart) -> Double;
    
    /// Asks the delegate for the number of items that will be drawn on the chart
    func numberOfItems(in lineChart: LineChart) -> Int;
}

public protocol LineChartDelegate: class {
    /// Informs the delegate the the item at the specified index was selected
    func lineChart(_ lineChart: LineChart, didSelectItemAt index: Int?);
}

public extension LineChartDataSource {
    func lineChart(_ lineChart: LineChart, axisXGridLineActiveForItemAt index: Int) -> Bool? {
        return nil;
    }

    func lineChart(_ lineChart: LineChart, axisXGridLineColorForItemAt index: Int) -> UIColor? {
        return nil;
    };

    func lineChart(_ lineChart: LineChart, axisXGridLineStyleForItemAt index: Int) -> ChartCore.LineStyle? {
        return nil;
    };

    func lineChart(_ lineChart: LineChart, axisXGridLineWidthForItemAt index: Int) -> CGFloat? {
        return nil;
    };
    
    func lineChart(_ lineChart: LineChart, sectionTitleForItemAt index: Int) -> String? {
        return nil;
    };
    
    func lineChart(_ lineChart: LineChart, sectionTitleColorForItemAt index: Int) -> UIColor? {
        return nil;
    };
    
    func lineChart(_ lineChart: LineChart, sectionTitleFontForItemAt index: Int) -> UIFont {
        return UIFont.preferredFont(forTextStyle: .caption1);
    };
    
    func lineChart(_ lineChart: LineChart, tooltipTitleForItemAt index: Int) -> String {
        return "Index \(index)";
    }
    
    func lineChart(_ lineChart: LineChart, tooltipValueForItemAt index: Int) -> String {
        return String(self.lineChart(lineChart, valueForItemAt: index));
    }
}

public extension LineChartDelegate {
    func lineChart(_ lineChart: LineChart, didSelectItemAt index: Int?) {
    };
}

public class LineChart: UIView, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    // Setup the data source
    public weak var dataSource: LineChartDataSource?;
    
    // Setup the delegate
    public weak var delegate: LineChartDelegate?;
    
    // MARK: - Enumerations
    
    // Point locations
    private enum SegmentLocation {
        case current;
        case next;
        case nextMid;
        case previous;
        case previousMid;
    }
    
    // MARK: - Structures
        
    /// Properties used in the drawing of lines
    public struct Line {
        /// The line segment's color if drawn below the zero axis
        public var negativeColor: UIColor = .systemRed;
        
        /// The line segment's color if drawn above the zero axis
        public var positiveColor: UIColor = .link;
        
        /// The line's width
        public var width: CGFloat = 2.0;
    }
    
    /// Properties used in the drawing of points on a line
    public struct Point {
        /// The circumference of the point
        public var circumference: CGFloat = 8.0;
        
        /// The point's color if drawn below the zero axis
        public var negativeColor: UIColor = .systemRed;
        
        /// The point's color when it has been selected if drawn below the zero axis
        public var negativeColorSelected: UIColor = ChartCore.blendColors(colors: [.systemRed, .black]);
        
        /// The point's color if drawn above the zero axis
        public var positiveColor: UIColor = .link;
        
        /// The point's color when it has been selected if drawn above the zero axis
        public var positiveColorSelected: UIColor = ChartCore.blendColors(colors: [.link, .black]);
        
        /// Determines if the point is drawn filled or hollow
        public var fill: Bool = false;
        
        /// The width of the border drawn around the point (if fill is set to false)
        public var width: CGFloat = 2.0;
    }
    
    /// Properties used in the drawing segments on the cart
    public struct Segment {
        /// The segment's fill color
        public var fillColor: UIColor = UIColor.link.withAlphaComponent(0.50);
        
        /// Properties used in the drawing of lines
        public var line: Line = Line();
        
        /// Properties used in the drawing of points
        public var point: Point = Point();
        
        /// The spacing between points
        public var spacing: CGFloat = 48.0;
    }
    
    /// Properties used to configure a chart's settings
    public struct Settings {
        /// The chart's background color
        public var backgroundColor: UIColor = .secondarySystemBackground;
        
        /// The chart's border
        public var border: ChartCore.Border = ChartCore.Border();
        
        /// The chart's corner radius
        public var cornerRadius: CGFloat = 8.0;
        
        /// Properties used in configuring the grid on the x-axis
        public var gridX: ChartCore.Grid = ChartCore.Grid(lineStyle: .dashed);
        
        /// Properties used in configuring the grid on the y-axis
        public var gridY: ChartCore.Grid = ChartCore.Grid();
        
        /// Properties used in configuring the axis lines on the y-axis
        public var gridYAxis: ChartCore.Grid = ChartCore.Grid(color: .systemRed, width: 1.00);
        
        /// The chart's initial scroll location after it has been drawn
        public var initialScrollLocation: ChartCore.ScrollLocation = .left;
        
        /// Properties used in configuring the line segments on a line chart
        public var segment: Segment = Segment();
        
        /// Padding applied to the left, top, right and bottom edges of the chart
        public var padding: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0);
        
        /// Properties used in the drawing of tooltips
        public var tooltip: ChartCore.Tooltip = ChartCore.Tooltip();
    }
    
    // MARK: - Variables
    
    /// The maximum value that will be displayed on the chart
    private var doubleMaxValue: Double = .zero;
    
    /// The minimum value that will be displayed on the chart
    private var doubleMinValue: Double = .zero;
    
    /// The currently selected index path
    private var indexPathSelected: IndexPath?;
    
    /// The current location and dimensions of the displayed tooltip
    private var rectTooltip: CGRect?;
    
    /// The chart's settings
    public var settings: Settings = Settings();
    
    // MARK: - General
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Check to see if the userInterfaceStyle or size class / orientation changed
        if (traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle || traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass || traitCollection.verticalSizeClass != previousTraitCollection?.verticalSizeClass) {
            // Retreive the previous collection view
            let collectionViewPrevious: UICollectionView? = self.subviews.filter({ $0.isKind(of: UICollectionView.classForCoder()) }).first as? UICollectionView;
            
            // Save the graph's current location
            let pointContentOffset: CGPoint? = collectionViewPrevious?.contentOffset;
            
            // Draw the chart
            self.draw(reset: false);
            
            // Retreive the new collection view
            let collectionViewNew: UICollectionView? = self.subviews.filter({ $0.isKind(of: UICollectionView.classForCoder()) }).first as? UICollectionView;
            
            // Restore the graph's previous location
            collectionViewNew?.contentOffset = pointContentOffset ?? CGPoint.zero;
            
            // Check to see if an index path is currently selected and that the associated cell has been created
            if (indexPathSelected != nil && collectionViewNew?.cellForItem(at: indexPathSelected!) != nil) {
                // Remove the old tooltip
                ChartCore.removeTooltip(in: collectionViewNew);

                // Draw the tooltip
                self.drawTooltip(for: (collectionViewNew?.cellForItem(at: indexPathSelected ?? IndexPath(row: 0, section: 0)))!, in: collectionViewNew!, at: indexPathSelected!);
            }
        }
    }
    
    // MARK: - Calculations
    
    /// Calculates the location of the specified point on the y-axis when drawing an individual line segment
    private func calculateSegmentLocationY(for cell: UICollectionViewCell, in collectionView: UICollectionView, location segmentLocation: SegmentLocation, at indexPath: IndexPath) -> CGFloat {
        // Calculate the location of the zero axis
        let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: cell,
                                                                         max: doubleMaxValue,
                                                                         min: doubleMinValue);
        
        // Calculate the location of the current point
        let floatLocationYCurrent: CGFloat = ChartCore.calculatePointLocationY(in: collectionView,
                                                                        payload: dataSource!.lineChart(self, valueForItemAt: indexPath.row),
                                                                        maxValue: doubleMaxValue,
                                                                        minValue: doubleMinValue);

        
        
        // Check to see which point is being requested
        if (segmentLocation == .current) {
            return floatZeroAxis - floatLocationYCurrent;
        } else if (segmentLocation == .next || segmentLocation == .nextMid) {
            // Check to see if any special circumstances are present
            if (indexPath.row == (dataSource!.numberOfItems(in: self) - 1)) {
                return floatZeroAxis - floatLocationYCurrent;
            } else {
                // Calculate the location of the next point
                let floatPointPositionYNext: CGFloat = ChartCore.calculatePointLocationY(in: collectionView,
                                                                                         payload: dataSource!.lineChart(self, valueForItemAt: indexPath.row + 1),
                                                                                         maxValue: doubleMaxValue,
                                                                                         minValue: doubleMinValue);
                
                if (segmentLocation == .next) {
                    return floatZeroAxis - floatPointPositionYNext;
                } else if (segmentLocation == .nextMid) {
                    // Calculate the difference between the two points on the Y-Axis
                    let floatDifference: CGFloat = floatPointPositionYNext - ((floatPointPositionYNext - floatLocationYCurrent) / 2);

                    return floatZeroAxis - floatDifference;
                }
            }
        } else if (segmentLocation == .previous || segmentLocation == .previousMid) {
            // Check to see if any special circumstances are present
            if (indexPath.row == 0) {
                return floatZeroAxis - floatLocationYCurrent;
            } else {
                // Calculate the location of the previous point
                let floatPointPositionYPrevious: CGFloat = ChartCore.calculatePointLocationY(in: collectionView,
                                                                                         payload: dataSource!.lineChart(self, valueForItemAt: indexPath.row - 1),
                                                                                         maxValue: doubleMaxValue,
                                                                                         minValue: doubleMinValue);
                
                if (segmentLocation == .previous) {
                    return floatZeroAxis - floatPointPositionYPrevious;
                } else if (segmentLocation == .previousMid) {
                    // Calculate the difference between the two points on the Y-Axis
                    let floatDifference: CGFloat = floatPointPositionYPrevious - ((floatPointPositionYPrevious - floatLocationYCurrent) / 2);

                    return floatZeroAxis - floatDifference;
                }
            }
        }

        return floatZeroAxis;
    }
    
    /// Calculates the location at which a line segment will cross the zero axis
    private func calculateZeroAxisCrossLocationX(currentPoint floatLocationYCurrent: CGFloat, midPoint floatLocationYMid: CGFloat, zeroAxis floatZeroAxis: CGFloat) -> CGFloat {
        // Calculate the distance between the midpoint and the zero axis
        let floatMidpointToZero: CGFloat = abs(floatLocationYMid - floatZeroAxis);
        
        // Calculate the distance between the midpoint and the current location
        let floatMidpointToCurrent: CGFloat = abs(floatLocationYMid - floatLocationYCurrent);
        
        // Calculate the percent that will be drawn prior to intersecting the zero axis
        let floatPercentDrawn: CGFloat = floatMidpointToZero / floatMidpointToCurrent;
        
        // Calcualte the cross location
        let floatCrossLocationX: CGFloat = ((self.settings.segment.spacing / 2) * floatPercentDrawn)
        
        return floatCrossLocationX;
    }
        
    // MARK: - Chart
    
    // Draws the chart
    public func draw(reset boolReset: Bool = true) {
        // Check to see if the state should be reset
        if (boolReset) {
            // Reset the selected indexPath
            indexPathSelected = nil;
            
            // Reset the location of the tooltip
            rectTooltip = nil;
        }
        
        // Remove the background color
        self.backgroundColor = .clear;
        
        // Clip the subviews
        self.clipsToBounds = true;
        
        // Remove all subviews
        self.subviews.forEach({ $0.removeFromSuperview(); });
        
        // Cache the maximum and minimum values that will be used by the chart
        doubleMaxValue = dataSource!.maxValue(in: self);
        doubleMinValue = dataSource!.minValue(in: self);
        
        // Configure the UICollectionViewFlowLayout
        let collectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        collectionViewFlowLayout.itemSize = CGSize(width: self.settings.segment.spacing, height: self.frame.size.height - self.settings.padding.top - self.settings.padding.bottom);
        collectionViewFlowLayout.minimumInteritemSpacing = CGFloat.zero;
        collectionViewFlowLayout.minimumLineSpacing = CGFloat.zero;
        collectionViewFlowLayout.scrollDirection = .horizontal;
        
        // Configure the UICollectionView
        let collectionView: UICollectionView = UICollectionView(frame: CGRect(x: CGFloat.zero, y: CGFloat.zero, width: self.frame.size.width, height: self.frame.size.height), collectionViewLayout: collectionViewFlowLayout);
        collectionView.backgroundView = UIView(frame: collectionView.frame);
        collectionView.backgroundView?.backgroundColor = self.settings.backgroundColor;
        collectionView.dataSource = self;
        collectionView.delegate = self;
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "collectionViewCell");
        collectionView.translatesAutoresizingMaskIntoConstraints = false;
        
        // Apply the settings
        collectionView.backgroundColor = self.settings.backgroundColor;
        collectionView.contentInset = self.settings.padding;
        collectionView.layer.cornerRadius = self.settings.cornerRadius;
        collectionView.layer.borderColor = self.settings.border.color?.cgColor ?? UIColor.clear.cgColor;
        collectionView.layer.borderWidth = self.settings.border.width;
        
        // Reload the collection view
        collectionView.reloadData();
                
        // Add the UICollectionView to the UIView
        self.addSubview(collectionView);
                
        // Add any required layout constraints
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: collectionView, attribute: .leading, multiplier: 1.0, constant: CGFloat.zero));
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1.0, constant: CGFloat.zero));
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: collectionView, attribute: .trailing, multiplier: 1.0, constant: CGFloat.zero));
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1.0, constant: CGFloat.zero));
        
        // Tell the view to layout if needed
        self.layoutIfNeeded();
        
        // Draw the Y-Axis grid
        self.drawAxisYGrid(for: collectionView, in: collectionView.backgroundView);
        
        // Draw the Zero Axis
        self.drawZeroAxis(for: collectionView, in: collectionView.backgroundView);
        
        // Check to see if the width of the collection view's content area is less than the width of the collection view
        if ((collectionView.contentInset.left + collectionView.contentSize.width + collectionView.contentInset.right) < collectionView.frame.size.width) {
            // Draw the X-Axis grid
            self.drawAxisXGrid(for: collectionView, in: collectionView.backgroundView);
        }
        
        // Set the initial scroll location
        collectionView.scrollToItem(at: self.settings.initialScrollLocation == .left ? IndexPath(row: 0, section: 0) : IndexPath(row: dataSource!.numberOfItems(in: self) - 1, section: 0),
                                    at: self.settings.initialScrollLocation == .left ? .left : .right,
                                    animated: false);
        
        // Add a gesture recognizer to the collection view
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognizer_Tap(sender:)));
        tapGestureRecognizer.delegate = self;
        collectionView.addGestureRecognizer(tapGestureRecognizer);
    }
    
    // MARK: - Delegates
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Retreive the new collection view
        let collectionView: UICollectionView? = self.subviews.filter({ $0.isKind(of: UICollectionView.classForCoder()) }).first as? UICollectionView;
        
        // Check to see if the touch event is contained within rectTooltip
        if (rectTooltip?.contains(touch.location(in: collectionView)) ?? false) {
            return true;
        }
        
        return false;
    }
    
    // MARK: - Drawing
    
    /// Draws the X-Axis grid for the cell
    private func drawAxisXGrid(in cell: UICollectionViewCell, at indexPath: IndexPath) {
        // Check to see if the grid should be drawn
        if (dataSource?.lineChart(self, axisXGridLineActiveForItemAt: indexPath.row) ?? self.settings.gridX.active) {
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: cell,
                                                                             max: doubleMaxValue,
                                                                             min: doubleMinValue);
            
            // Draw a grid line (above the zero axis)
            ChartCore.drawLine(from: CGPoint(x: 0, y: floatZeroAxis),
                               to: CGPoint(x: 0, y: 0 - self.settings.padding.top),
                               color: dataSource!.lineChart(self, axisXGridLineColorForItemAt: indexPath.row) ?? self.settings.gridX.color,
                               style: dataSource!.lineChart(self, axisXGridLineStyleForItemAt: indexPath.row) ?? self.settings.gridX.lineStyle,
                               width: dataSource!.lineChart(self, axisXGridLineWidthForItemAt: indexPath.row) ?? self.settings.gridX.width,
                               in: cell.contentView);
            
            // Draw a grid line (below the zero axis)
            ChartCore.drawLine(from: CGPoint(x: 0, y: floatZeroAxis),
                               to: CGPoint(x: 0, y: cell.frame.size.height + self.settings.padding.bottom),
                               color: dataSource!.lineChart(self, axisXGridLineColorForItemAt: indexPath.row) ?? self.settings.gridX.color,
                               style: dataSource!.lineChart(self, axisXGridLineStyleForItemAt: indexPath.row) ?? self.settings.gridX.lineStyle,
                               invertLineStyle: true,
                               width: dataSource!.lineChart(self, axisXGridLineWidthForItemAt: indexPath.row) ?? self.settings.gridX.width,
                               in: cell.contentView);
        }
    }
    
    /// Draws the X-Axis grid for the collection view
    private func drawAxisXGrid(for collectionView: UICollectionView, in view: UIView?) {
        // Check to see if the grid should be drawn
        if (self.settings.gridX.active) {
            // Calculate the incriment between the center of each bar
            let floatIncriment: CGFloat = self.settings.segment.spacing;
            
            // Calculate the starting location on the X-Axis
            var floatLocationX: CGFloat = self.settings.padding.left;
            
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: collectionView,
                                                                             max: doubleMaxValue,
                                                                             min: doubleMinValue);
            
            // Loop through drawing the grid on the collection view's background view
            repeat {
                // Draw a grid line (above the zero axis)
                ChartCore.drawLine(from: CGPoint(x: floatLocationX, y: floatZeroAxis),
                                   to: CGPoint(x: floatLocationX, y: 0),
                                   color: self.settings.gridX.color,
                                   style: self.settings.gridX.lineStyle,
                                   width: self.settings.gridX.width,
                                   in: view);
                
                // Draw a grid line (below the zero axis)
                ChartCore.drawLine(from: CGPoint(x: floatLocationX, y: floatZeroAxis),
                                   to: CGPoint(x: floatLocationX, y: view?.frame.size.height ?? 0),
                                   color: self.settings.gridX.color,
                                   style: self.settings.gridX.lineStyle,
                                   invertLineStyle: true,
                                   width: self.settings.gridX.width,
                                   in: view);
                
                // Incriment floatLocation
                floatLocationX += floatIncriment;
            } while floatLocationX < view?.frame.size.width ?? 0;
        }
    }
    
    /// Draws the X-Axis grid for the cell
    private func drawAxisXGridTitle(in cell: UICollectionViewCell, at indexPath: IndexPath) {
        // Draw the text
        ChartCore.drawText(from: CGPoint(x: 0, y: 0),
                           direction: .bottomToTop,
                           text: dataSource!.lineChart(self, sectionTitleForItemAt: indexPath.row) ?? "",
                           color: dataSource!.lineChart(self, sectionTitleColorForItemAt: indexPath.row) ?? self.settings.gridX.color,
                           font: dataSource!.lineChart(self, sectionTitleFontForItemAt: indexPath.row),
                           in: cell.contentView);
        
    }
    
    /// Draws the Y-Axis grid for the collection view in it's background view
    private func drawAxisYGrid(for collectionView: UICollectionView, in view: UIView?) {
        // Check to see if the grid should be drawn
        if (self.settings.gridY.active) {
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: collectionView,
                                                                             max: doubleMaxValue,
                                                                             min: doubleMinValue) + self.settings.padding.top;

            // Calculate the incriment
            let floatIncriment: CGFloat = ChartCore.calculateIncriment(in: collectionView,
                                                                       maxValue: doubleMaxValue,
                                                                       minValue: doubleMinValue);
            
            // Set floatYLocation to the zero axis
            var floatYLocation: CGFloat = floatZeroAxis;
            
            // Loop through drawing the grid above the zero axis
            repeat {
                // Incriment floatYLocation
                floatYLocation -= floatIncriment;
                
                // Draw a grid line
                ChartCore.drawLine(from: CGPoint(x: 0, y: floatYLocation),
                                   to: CGPoint(x: view?.frame.size.width ?? 0, y: floatYLocation),
                                   color: self.settings.gridY.color,
                                   style: self.settings.gridY.lineStyle,
                                   width: self.settings.gridY.width,
                                   in: view);
            } while (floatYLocation - floatIncriment) >= 0
            
            // Reset floatYLocation to the zero axis
            floatYLocation = floatZeroAxis;

            // Loop through drawing the grid below the zero axis
            repeat {
                // Deincriment floatYLocation
                floatYLocation += floatIncriment;
                
                // Draw a grid line
                ChartCore.drawLine(from: CGPoint(x: 0, y: floatYLocation),
                                   to: CGPoint(x: view?.frame.size.width ?? 0, y: floatYLocation),
                                   color: self.settings.gridY.color,
                                   style: self.settings.gridY.lineStyle,
                                   width: self.settings.gridY.width,
                                   in: view);
            } while (floatYLocation + floatIncriment) <= (view?.frame.size.height ?? 0)
        }
    }
    
    /// Draws the line segment for the specified cell
    private func drawLineSegment(for cell: UICollectionViewCell, in collectionView: UICollectionView, at indexPath: IndexPath) {
        // Calculate the location of the zero axis
        let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: cell,
                                                                         max: doubleMaxValue,
                                                                         min: doubleMinValue);
        
        // Calculate the location of the current point
        let floatLocationYCurrent: CGFloat = self.calculateSegmentLocationY(for: cell,
                                                                            in: collectionView,
                                                                            location: .current,
                                                                            at: indexPath);
        
        // Calculate the location of the next point's midpoint
        let floatLocationYNextMid: CGFloat = self.calculateSegmentLocationY(for: cell,
                                                                         in: collectionView,
                                                                         location: .nextMid,
                                                                         at: indexPath);
        
        // Calculate the location of the previous point's midpoint
        let floatLocationYPreviousMid: CGFloat = self.calculateSegmentLocationY(for: cell,
                                                                             in: collectionView,
                                                                             location: .previousMid,
                                                                             at: indexPath);
        
        // Calculate the location at which the zero axis will be crossed when drawing a line from the previous point to the current point
        let floatZeroAxisCrossLocationXPrevious: CGFloat = self.calculateZeroAxisCrossLocationX(currentPoint: floatLocationYCurrent,
                                                                         midPoint: floatLocationYPreviousMid,
                                                                         zeroAxis: floatZeroAxis);
        
        // Calculate the location at which the zero axis will be crossed when drawing a line from the current point to the next point
        let floatZeroAxisCrossLocationXNext: CGFloat = cell.contentView.frame.size.width - self.calculateZeroAxisCrossLocationX(currentPoint: floatLocationYCurrent,
                                                                                                                                midPoint: floatLocationYNextMid,
                                                                                                                                zeroAxis: floatZeroAxis);
        
        // Check to see if the cell should have any extra padding applied
        let floatPaddingAdjustmentLeft: CGFloat = indexPath.row == 0 ? self.settings.padding.left : 0;
        let floatPaddingAdjustmentRight: CGFloat = indexPath.row == (collectionView.numberOfItems(inSection: 0) - 1) ? self.settings.padding.right : 0;
        
        
        // Calculate all of the points needed to draw the line segments
        let pointPreviousMid: CGPoint = CGPoint(x: .zero - floatPaddingAdjustmentLeft, y: floatLocationYPreviousMid);
        let pointPreviousCrossZeroAxis: CGPoint = CGPoint(x: floatZeroAxisCrossLocationXPrevious, y: floatZeroAxis);
        let pointCurrent: CGPoint = CGPoint(x: (self.settings.segment.spacing / 2), y: floatLocationYCurrent);
        let pointNextCrossZeroAxis: CGPoint = CGPoint(x: floatZeroAxisCrossLocationXNext, y: floatZeroAxis);
        let pointNextMid: CGPoint = CGPoint(x: cell.contentView.frame.size.width + floatPaddingAdjustmentRight, y: floatLocationYNextMid);
        let pointCellBottomRight: CGPoint = CGPoint(x: cell.contentView.frame.size.width + floatPaddingAdjustmentRight, y: cell.contentView.frame.size.height + self.settings.padding.bottom);
        let pointCellBottomLeft: CGPoint = CGPoint(x: .zero - floatPaddingAdjustmentLeft, y: cell.contentView.frame.size.height + self.settings.padding.bottom);
        
        
        // Draw a shape that fills the content view below the line segment
        ChartCore.drawShape(points: [pointPreviousMid,
                                     pointCurrent,
                                     pointNextMid,
                                     pointCellBottomRight,
                                     pointCellBottomLeft],
                            color: self.settings.segment.fillColor,
                            in: cell.contentView);
        
        // Check to see if the line segment will cross the zero axis
        if ((floatLocationYPreviousMid >= floatZeroAxis && floatLocationYCurrent >= floatZeroAxis) || (floatLocationYPreviousMid <= floatZeroAxis && floatLocationYCurrent <= floatZeroAxis)) {
            // Draw a line segment from the start point to the end point
            ChartCore.drawLine(from: pointPreviousMid,
                               to: pointCurrent,
                               color: floatLocationYCurrent <= floatZeroAxis ? self.settings.segment.line.positiveColor : self.settings.segment.line.negativeColor,
                               width: self.settings.segment.line.width,
                               in: cell.contentView);
        } else {
            // Draw a line segment from the start point to the zero axis cross point
            ChartCore.drawLine(from: pointPreviousMid,
                               to: pointPreviousCrossZeroAxis,
                               color: pointPreviousMid.y <= pointPreviousCrossZeroAxis.y ? self.settings.segment.line.positiveColor : self.settings.segment.line.negativeColor,
                               width: self.settings.segment.line.width,
                               in: cell.contentView);
            
            // Draw a line segment from the zero axis cross point to the end point
            ChartCore.drawLine(from: pointPreviousCrossZeroAxis,
                               to: pointCurrent,
                               color: pointCurrent.y <= pointPreviousCrossZeroAxis.y ? self.settings.segment.line.positiveColor : self.settings.segment.line.negativeColor,
                               width: self.settings.segment.line.width,
                               in: cell.contentView);
        }
        
        // Check to see if the line segment will cross the zero axis
        if ((floatLocationYCurrent >= floatZeroAxis && floatLocationYNextMid >= floatZeroAxis) || (floatLocationYCurrent <= floatZeroAxis && floatLocationYNextMid <= floatZeroAxis)) {
            // Draw a line segment from the start point to the end point
            ChartCore.drawLine(from: pointCurrent,
                               to: pointNextMid,
                               color: floatLocationYCurrent <= floatZeroAxis ? self.settings.segment.line.positiveColor : self.settings.segment.line.negativeColor,
                               width: self.settings.segment.line.width,
                               in: cell.contentView);
        } else {
            // Draw a line segment from the start point to the zero axis cross point
            ChartCore.drawLine(from: pointCurrent,
                               to: pointNextCrossZeroAxis,
                               color: pointCurrent.y <= pointNextCrossZeroAxis.y ? self.settings.segment.line.positiveColor : self.settings.segment.line.negativeColor,
                               width: self.settings.segment.line.width,
                               in: cell.contentView);
            
            // Draw a line segment from the zero axis cross point to the end point
            ChartCore.drawLine(from: pointNextCrossZeroAxis,
                               to: pointNextMid,
                               color: pointNextMid.y <= pointNextCrossZeroAxis.y ? self.settings.segment.line.positiveColor : self.settings.segment.line.negativeColor,
                               width: self.settings.segment.line.width,
                               in: cell.contentView);
        }
    }
    
    /// Draws the point for the specified cell
    private func drawPoint(for cell: UICollectionViewCell, in collectionView: UICollectionView, at indexPath: IndexPath, selected boolSelected: Bool) {
        // Calculate the location of the zero axis
        let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: cell,
                                                                         max: doubleMaxValue,
                                                                         min: doubleMinValue);
        
        // Calculate the location of the point on the Y-Axis
        let floatLocationY: CGFloat = ChartCore.calculatePointLocationY(in: collectionView,
                                                                        payload: dataSource!.lineChart(self, valueForItemAt: indexPath.row),
                                                                        maxValue: doubleMaxValue,
                                                                        minValue: doubleMinValue);
        
        // Determine what border color should be used
        var colorPointBorder: UIColor {
            // Check to see if a point is less than or greater than zero and if it is selected
            if (0 <= floatLocationY && indexPath != indexPathSelected) {
                return self.settings.segment.point.positiveColor;
            } else if (0 <= floatLocationY && indexPath == indexPathSelected) {
                return self.settings.segment.point.positiveColorSelected;
            } else if (0 > floatLocationY && indexPath != indexPathSelected) {
                return self.settings.segment.point.negativeColor;
            } else if (0 > floatLocationY && indexPath == indexPathSelected) {
                return self.settings.segment.point.negativeColorSelected;
            } else {
                return self.settings.segment.point.positiveColor;
            }
        };
            
        // Draw the point
        ChartCore.drawCircle(from: CGPoint(x: (self.settings.segment.spacing / 2), y: floatZeroAxis - floatLocationY),
                             circumference: self.settings.segment.point.circumference,
                             borderColor: colorPointBorder,
                             borderWidth: self.settings.segment.point.width,
                             fillColor: self.settings.segment.point.fill ? colorPointBorder : self.settings.backgroundColor,
                             in: cell.contentView);
    }
    
    /// Draws the tooltip if the index path has been selected
    private func drawTooltip(for cell: UICollectionViewCell, in collectionView: UICollectionView, at indexPath: IndexPath) {
        // Check to see if the selected index path is the current index path
        if (indexPathSelected == indexPath) {
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: cell,
                                                                             max: doubleMaxValue,
                                                                             min: doubleMinValue);

            // Calculate the location of the point on the Y-Axis
            let floatLocationY: CGFloat = ChartCore.calculatePointLocationY(in: collectionView,
                                                                            payload: dataSource!.lineChart(self, valueForItemAt: indexPath.row),
                                                                            maxValue: doubleMaxValue,
                                                                            minValue: doubleMinValue);
            
            // Setup an array to house tooltip direction attributes
            var arrayTooltipDirection: [ChartCore.TooltipDirection] = [];
            
            // Check to see what direction the tooltip should open
            if ((floatZeroAxis - floatLocationY) > (cell.contentView.frame.size.height / 2)) {
                // Draw the tooltip upwards
                arrayTooltipDirection.append(.up);
            } else {
                // Draw the tooltip downwards
                arrayTooltipDirection.append(.down);
            }
            
            // Check to see if the tooltip needs to be adjusted to the left or the right
            if (indexPath.row == 0) {
                // Draw the tooltip to the right
                arrayTooltipDirection.append(.right);
            } else if (indexPath.row == (dataSource!.numberOfItems(in: self) - 1)) {
                // Draw the tooltip to the left
                arrayTooltipDirection.append(.left);
            }
            
            // Calculate the location of the point where the tooltip should originate from in the cell
            let pointFrom: CGPoint = CGPoint(x: (self.settings.segment.spacing / 2), y: floatZeroAxis - floatLocationY);
            
            // Convert the location of the point from the cell to the collection view
            let pointFromCollectionView: CGPoint = cell.convert(pointFrom, to: collectionView);
            
            // Draw the tooltip
            let rectTooltipLocal: CGRect? = ChartCore.drawTooltip(from: pointFromCollectionView,
                                                direction: arrayTooltipDirection,
                                                title: dataSource!.lineChart(self, tooltipTitleForItemAt: indexPath.row),
                                                value: dataSource!.lineChart(self, tooltipValueForItemAt: indexPath.row),
                                                settings: self.settings.tooltip,
                                                in: collectionView);
            
            // Save the location of the tooltip to a local variable
            rectTooltip = rectTooltipLocal;
        }
    }
    
    /// Draws the zero axis for the collection view in the specified view
    private func drawZeroAxis(for object: AnyObject, adjustLeft boolAdjustLeft: Bool = false, adjustRight boolAdjustRight: Bool = false, in view: UIView?) {
        // Calculate floatHeight
        var floatPaddingTop: CGFloat {
            // Check to see which object is requesting the zero axis height
            if (object.isKind(of: UICollectionView.classForCoder())) {
                return self.settings.padding.top;
            } else if (object.isKind(of: UICollectionViewCell.classForCoder())) {
                return 0;
            }
            
            return CGFloat.zero;
        };
        
        // Check to see if the zero axis should be drawn
        if (self.settings.gridYAxis.active) {
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: object,
                                                                             max: doubleMaxValue,
                                                                             min: doubleMinValue) + floatPaddingTop;

            // Draw a grid line
            ChartCore.drawLine(from: CGPoint(x: .zero - (boolAdjustLeft ? self.settings.padding.left : .zero), y: floatZeroAxis),
                               to: CGPoint(x: (view?.frame.size.width ?? .zero) + (boolAdjustRight ? self.settings.padding.right : .zero), y: floatZeroAxis),
                               color: self.settings.gridYAxis.color,
                               style: self.settings.gridYAxis.lineStyle,
                               width: self.settings.gridYAxis.width,
                               in: view);
        }
    }
    
    // MARK: - UICollectionView
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Setup access to the cell
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath);
        
        // Remove all subviews
        cell.contentView.subviews.forEach({ $0.removeFromSuperview(); });
        
        // Remove all sublayers
        cell.contentView.layer.sublayers?.forEach({ $0.removeFromSuperlayer(); });
        
        // Draw the X-Axis grid
        self.drawAxisXGrid(in: cell, at: indexPath);

        // Draw the X-Axis grid title
        self.drawAxisXGridTitle(in: cell, at: indexPath);
        
        // Draw the line segment and fill
        self.drawLineSegment(for: cell, in: collectionView, at: indexPath);
        
        // Draw the Zero Axis
        self.drawZeroAxis(for: cell, adjustLeft: indexPath.row == 0, adjustRight: indexPath.row == dataSource!.numberOfItems(in: self) - 1, in: cell.contentView);

        // Draw the point
        self.drawPoint(for: cell, in: collectionView, at: indexPath, selected: indexPath == indexPathSelected)

        // Draw the tooltip
        self.drawTooltip(for: cell, in: collectionView, at: indexPath);
        
        return cell;
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Record the previously selected index path
        let indexPathPrevious: IndexPath? = indexPathSelected;
        
        // Check to see if the current index path is the same as the selected index path
        if (indexPath == indexPathSelected) {
            // Reset the selected indexPath
            indexPathSelected = nil;
            
            // Reset the location of the tooltip
            rectTooltip = nil;
        } else {
            // Set the selected indexPath
            indexPathSelected = indexPath;
        }
        
        // Remove the old tooltip
        ChartCore.removeTooltip(in: collectionView);
        
        // Check to see if we need to reload the currently selected cell, or the currently selected cell and the previously selected cell
        if (indexPathPrevious != nil && indexPath != indexPathPrevious) {
            // Reload the cells with no animation
            UIView.performWithoutAnimation {
                // Reload the previously selected cell
                collectionView.reloadItems(at: [indexPathPrevious!]);
                
                // Reload the selected cell
                collectionView.reloadItems(at: [indexPath]);
            }
        } else {
            
            // Reload the cells with no animation
            UIView.performWithoutAnimation {
                // Reload the selected cell
                collectionView.reloadItems(at: [indexPath]);
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource!.numberOfItems(in: self);
    }
    
    // MARK: - UITapGestureRecognizer
    
    @objc private func tapGestureRecognizer_Tap(sender: UITapGestureRecognizer) {
        // Inform the delegate that the tooltip was tapped
        delegate?.lineChart(self, didSelectItemAt: indexPathSelected?.row ?? nil);
    }
}
