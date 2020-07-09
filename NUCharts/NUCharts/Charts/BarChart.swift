//
//  BarChart.swift
//  NUCharts
//
//  Created by Jason Cox on 6/11/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

import UIKit

public protocol BarChartDataSource: class {
    /// Asks the delegate whether the X-Axis grid line should be shown
    func barChart(_ barChart: BarChart, axisXGridLineActiveForItemAt index: Int) -> Bool?;
    
    /// Asks the delegate what the color of the X-Axis grid line should be
    func barChart(_ barChart: BarChart, axisXGridLineColorForItemAt index: Int) -> UIColor?;
    
    /// Asks the delegate what the line style of the X-Axis grid line should be
    func barChart(_ barChart: BarChart, axisXGridLineStyleForItemAt index: Int) -> ChartCore.LineStyle?;
    
    /// Asks the delegate what the width of the X-Axis grid line should be
    func barChart(_ barChart: BarChart, axisXGridLineWidthForItemAt index: Int) -> CGFloat?;
    
    /// Asks the delegate for the title of this section
    func barChart(_ barChart: BarChart, sectionTitleForItemAt index: Int) -> String?;
    
    /// Asks the delegate what the color of the section title should be
    func barChart(_ barChart: BarChart, sectionTitleColorForItemAt index: Int) -> UIColor?;
    
    /// Asks the delegate what the font of the section title should be
    func barChart(_ barChart: BarChart, sectionTitleFontForItemAt index: Int) -> UIFont;
    
    /// Asks the delegate what the title for the tooltip should be
    func barChart(_ barChart: BarChart, tooltipTitleForItemAt index: Int) -> String;
    
    /// Asks the delegate what the value for the tooltip should be
    func barChart(_ barChart: BarChart, tooltipValueForItemAt index: Int) -> String;
    
    /// Asks the delegate for the number of items that will be drawn on the chart
    func numberOfItems(in barChart: BarChart) -> Int;
    
    /// Asks the delegate for an array of values which will be drawn on the chart
    func values(for barChart: BarChart) -> [Double];
}

public protocol BarChartDelegate: class {
    /// Informs the delegate the the item at the specified index was selected
    func barChart(_ barChart: BarChart, didSelectItemAt index: Int?);
}

public extension BarChartDataSource {
    func barChart(_ barChart: BarChart, axisXGridLineActiveForItemAt index: Int) -> Bool? {
        return nil;
    }

    func barChart(_ barChart: BarChart, axisXGridLineColorForItemAt index: Int) -> UIColor? {
        return nil;
    }

    func barChart(_ barChart: BarChart, axisXGridLineStyleForItemAt index: Int) -> ChartCore.LineStyle? {
        return nil;
    }

    func barChart(_ barChart: BarChart, axisXGridLineWidthForItemAt index: Int) -> CGFloat? {
        return nil;
    }
    
    func barChart(_ barChart: BarChart, sectionTitleForItemAt index: Int) -> String? {
        return nil;
    }
    
    func barChart(_ barChart: BarChart, sectionTitleColorForItemAt index: Int) -> UIColor? {
        return nil;
    }
    
    func barChart(_ barChart: BarChart, sectionTitleFontForItemAt index: Int) -> UIFont {
        return UIFont.preferredFont(forTextStyle: .caption1);
    }
    
    func barChart(_ barChart: BarChart, tooltipTitleForItemAt index: Int) -> String {
        return "Index \(index)";
    }
    
    func barChart(_ barChart: BarChart, tooltipValueForItemAt index: Int) -> String {
        return String(self.values(for: barChart)[index]);
    }
    
    func numberOfItems(in barChart: BarChart) -> Int {
        return self.values(for: barChart).count;
    }
    
    func values(for barChart: BarChart) -> [Double] {
        return [];
    }
}

public extension BarChartDelegate {
    func barChart(_ barChart: BarChart, didSelectItemAt index: Int?) {
    };
}

public class BarChart: UIView, UICollectionViewDataSource , UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {
    // Setup the data source
    public weak var dataSource: BarChartDataSource?;
    
    // Setup the delegate
    public weak var delegate: BarChartDelegate?;
    
    // MARK: - Structures
    
    /// Properties used in the drawing of bars on a bar chart
    public struct Bar {
        /// The bar's corner radii
        public var cornerRadii: ChartCore.CornerRadii = ChartCore.CornerRadii(bottomLeft: CGFloat.zero, bottomRight: CGFloat.zero, topLeft: 4.0, topRight: 4.0);
        
        /// The bar's negative color
        public var negativeColor: UIColor = .systemRed;
        
        /// The bar's negative positive color when it has been selected
        public var negativeSelectedColor: UIColor = ChartCore.blendColors(colors: [.systemRed, .black]);
        
        /// The bar's positive color
        public var positiveColor: UIColor = .link;
        
        /// The bar's positive color when it has been selected
        public var positiveSelectedColor: UIColor = ChartCore.blendColors(colors: [.link, .black]);
                
        /// The spacing between bars
        public var spacing: CGFloat = 16.0;
        
        /// The bar's width
        public var width: CGFloat = 32.0;
    }
    
    /// Properties used to configure a chart's settings
    public struct Settings {
        /// The chart's background color
        public var backgroundColor: UIColor = .secondarySystemBackground;
        
        /// Properties used in configuring the bars on a bar chart
        public var bar: Bar = Bar();
        
        /// The chart's border
        public var border: ChartCore.Border = ChartCore.Border();
        
        /// The chart's corner radius
        public var cornerRadius: CGFloat = 8.0;
        
        /// Properties used in configuring the grid on the x-axis
        public var gridX: ChartCore.Grid = ChartCore.Grid(lineStyle: .dashed);
        
        /// Properties used in configuring the grid on the y-axis
        public var gridY: ChartCore.Grid = ChartCore.Grid();
        
        /// Properties used in configuring the axis lines on the y-axis
        public var gridYAxis: ChartCore.Grid = ChartCore.Grid(color: .systemRed);
        
        /// Padding applied to the left, top, right and bottom edges of the chart
        public var padding: UIEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0);
        
        /// Properties used in the drawing of tooltips
        public var tooltip: ChartCore.Tooltip = ChartCore.Tooltip();
    }
    
    // MARK: - Variables
    
    // TODO: Considering caching some variables to see if that speeds things up on HUGE (10,000+) draw requests
    
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
        
        // Remove all subviews
        self.subviews.forEach({ $0.removeFromSuperview(); });
        
        // Configure the UICollectionViewFlowLayout
        let collectionViewFlowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout();
        collectionViewFlowLayout.itemSize = CGSize(width: (self.settings.bar.width + self.settings.bar.spacing), height: self.frame.size.height - self.settings.padding.top - self.settings.padding.bottom);
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
        collectionView.layer.borderColor = self.settings.border.color.cgColor;
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
        if (dataSource?.barChart(self, axisXGridLineActiveForItemAt: indexPath.row) ?? self.settings.gridX.active) {
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: cell, with: dataSource!.values(for: self));
            
            // Draw a grid line (above the zero axis)
            ChartCore.drawLine(from: CGPoint(x: 0, y: floatZeroAxis),
                               to: CGPoint(x: 0, y: 0 - self.settings.padding.top),
                               color: dataSource!.barChart(self, axisXGridLineColorForItemAt: indexPath.row) ?? self.settings.gridX.color,
                               style: dataSource!.barChart(self, axisXGridLineStyleForItemAt: indexPath.row) ?? self.settings.gridX.lineStyle,
                               width: dataSource!.barChart(self, axisXGridLineWidthForItemAt: indexPath.row) ?? self.settings.gridX.width,
                               in: cell.contentView);
            
            // Draw a grid line (below the zero axis)
            ChartCore.drawLine(from: CGPoint(x: 0, y: floatZeroAxis),
                               to: CGPoint(x: 0, y: cell.frame.size.height + self.settings.padding.bottom),
                               color: dataSource!.barChart(self, axisXGridLineColorForItemAt: indexPath.row) ?? self.settings.gridX.color,
                               style: dataSource!.barChart(self, axisXGridLineStyleForItemAt: indexPath.row) ?? self.settings.gridX.lineStyle,
                               invertLineStyle: true,
                               width: dataSource!.barChart(self, axisXGridLineWidthForItemAt: indexPath.row) ?? self.settings.gridX.width,
                               in: cell.contentView);
        }
    }
    
    /// Draws the X-Axis grid for the collection view
    private func drawAxisXGrid(for collectionView: UICollectionView, in view: UIView?) {
        // Check to see if the grid should be drawn
        if (self.settings.gridX.active) {
            // Calculate the incriment between the center of each bar
            let floatIncriment: CGFloat = self.settings.bar.spacing + self.settings.bar.width;
            
            // Calculate the starting location on the X-Axis
            var floatLocationX: CGFloat = self.settings.padding.left;
            
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: collectionView, with: dataSource!.values(for: self)) + self.settings.padding.top;
            
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
                           text: dataSource!.barChart(self, sectionTitleForItemAt: indexPath.row) ?? "",
                           color: dataSource!.barChart(self, sectionTitleColorForItemAt: indexPath.row) ?? self.settings.gridX.color,
                           font: dataSource!.barChart(self, sectionTitleFontForItemAt: indexPath.row),
                           in: cell.contentView);
        
    }
    
    /// Draws the Y-Axis grid for the collection view in it's background view
    private func drawAxisYGrid(for collectionView: UICollectionView, in view: UIView?) {
        // Check to see if the grid should be drawn
        if (self.settings.gridY.active) {
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: collectionView, with: dataSource!.values(for: self)) + self.settings.padding.top;

            // Calculate the incriment
            let floatIncriment: CGFloat = ChartCore.calculateIncriment(in: collectionView, with: dataSource!.values(for: self));
            
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
    
    /// Draws the graph bar for the specified cell
    private func drawBar(for cell: UICollectionViewCell, in collectionView: UICollectionView, at indexPath: IndexPath, selected boolSelected: Bool) {
        // Calculate the location of the zero axis
        let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: cell, with: dataSource!.values(for: self));
        
        // Calculate the height of the bar
        let floatLocationY: CGFloat = ChartCore.calculatePointLocationY(in: collectionView,
                                                                        with: dataSource!.values(for: self),
                                                                        at: indexPath);
        
        // Determine what bar color should be used
        var colorBar: UIColor {
            // Check to see if a point is less than or greater than zero and if it is selected
            if (0 <= floatLocationY && indexPath != indexPathSelected) {
                return self.settings.bar.positiveColor;
            } else if (0 <= floatLocationY && indexPath == indexPathSelected) {
                return self.settings.bar.positiveSelectedColor;
            } else if (0 > floatLocationY && indexPath != indexPathSelected) {
                return self.settings.bar.negativeColor;
            } else if (0 > floatLocationY && indexPath == indexPathSelected) {
                return self.settings.bar.negativeSelectedColor;
            } else {
                return self.settings.bar.positiveColor;
            }
        };
        
        // Draw a rectangle
        ChartCore.drawRectangle(from: CGPoint(x: self.settings.bar.spacing / 2, y: floatZeroAxis),
                                width: self.settings.bar.width,
                                height: floatLocationY,
                                cornerRadii: self.settings.bar.cornerRadii,
                                color: colorBar,
                                in: cell.contentView);
    }
    
    /// Draws the tooltip if the index path has been selected
    private func drawTooltip(for cell: UICollectionViewCell, in collectionView: UICollectionView, at indexPath: IndexPath) {
        // Check to see if the selected index path is the current index path
        if (indexPathSelected == indexPath) {
            // Calculate the location of the zero axis
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: cell, with: dataSource!.values(for: self));

            // Calculate the height of the bar
            let floatLocationY: CGFloat = ChartCore.calculatePointLocationY(in: collectionView,
                                                                            with: dataSource!.values(for: self),
                                                                            at: indexPath);
                        
            // Setup an array to house tooltip direction attributes
            var arrayTooltipDirection: [ChartCore.TooltipDirection] = [];
            
            // Check to see what direction the tooltip should open
            if ((floatZeroAxis - (floatLocationY / 2)) > (cell.contentView.frame.size.height / 2)) {
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
            let pointFrom: CGPoint = CGPoint(x: (self.settings.bar.spacing / 2) + (self.settings.bar.width / 2), y: floatZeroAxis - (floatLocationY / 2));
            
            // Convert the location of the point from the cell to the collection view
            let pointFromCollectionView: CGPoint = cell.convert(pointFrom, to: collectionView);
            
            // Draw the tooltip
            let rectTooltipLocal: CGRect? = ChartCore.drawTooltip(from: pointFromCollectionView,
                                                direction: arrayTooltipDirection,
                                                title: dataSource!.barChart(self, tooltipTitleForItemAt: indexPath.row),
                                                value: dataSource!.barChart(self, tooltipValueForItemAt: indexPath.row),
                                                settings: self.settings.tooltip,
                                                in: collectionView);
            
            // Save the location of the tooltip to a local variable
            rectTooltip = rectTooltipLocal;
        }
    }
    
    /// Draws the zero axis for the collection view in the specified view
    private func drawZeroAxis(for object: AnyObject, in view: UIView?) {
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
            let floatZeroAxis: CGFloat = ChartCore.calculateZeroAxisLocation(for: object, with: dataSource!.values(for: self)) + floatPaddingTop;
            
            // Draw a grid line
            ChartCore.drawLine(from: CGPoint(x: 0, y: floatZeroAxis),
                               to: CGPoint(x: view?.frame.size.width ?? 0, y: floatZeroAxis),
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
        
        // Draw the bar
        self.drawBar(for: cell, in: collectionView, at: indexPath, selected: indexPath == indexPathSelected);
        
        // Draw the Zero Axis
        self.drawZeroAxis(for: cell, in: cell.contentView);
        
        // Draw the tooltip
        self.drawTooltip(for: cell, in: collectionView, at: indexPath)
        
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
            // Note: We need to reload each cell individually as there's no guarantee what order the cells will be reloaded in if we pass them both in the same array
            
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
        delegate?.barChart(self, didSelectItemAt: indexPathSelected?.row ?? nil);
    }
}
