//
//  ChartCore.swift
//  NUCharts
//
//  Created by Jason Cox on 6/11/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

import UIKit

public class ChartCore {
    
    // MARK: - Enumerations
    
    /// Line styles
    public enum LineStyle {
        case dashed;
        case dashedShort;
        case dotted;
        case solid;
    }
    
    /// Text drawing direction
    internal enum TextDrawingDirection {
        case bottomToTop;
        case leftToRight;
        case topToBottom;
    }
    
    /// Tooltip directions
    internal enum TooltipDirection {
        case down;
        case left;
        case right;
        case up;
    }
    
    /// Value Types
    public enum ValueType {
        case integer;
        case double;
    }
    
    // MARK: - Structures
    
    /// Properties used in the drawing of borders
    public struct Border {
        /// The border's color
        public var color: UIColor = .opaqueSeparator;
        
        /// The border's width
        public var width: CGFloat = 0.33;
    }
    
    /// Corner radius values for each of the four corners
    public struct CornerRadii {
        /// The corner radius of the bottom-left corner
        public var bottomLeft: CGFloat = .zero;
        
        /// The corner radius of the bottom-right corner
        public var bottomRight: CGFloat = .zero;
        
        /// The corner radius of the top-left corner
        public var topLeft: CGFloat = .zero;
        
        /// The corner radius of the top-right corner
        public var topRight: CGFloat = .zero;

        // Create the initializer
        public init(bottomLeft floatBottomLeft: CGFloat = .zero, bottomRight floatBottomRight: CGFloat = .zero, topLeft floatTopLeft: CGFloat = .zero, topRight floatTopRight: CGFloat = .zero) {
            self.bottomLeft = floatBottomLeft;
            self.bottomRight = floatBottomRight;
            self.topLeft = floatTopLeft;
            self.topRight = floatTopRight;
        }
    }
    
    /// Properties used in the drawing of grids
    public struct Grid {
        /// Controls whether the grid is drawn
        public var active: Bool = true;
        
        /// The grid line's color
        public var color: UIColor = .opaqueSeparator;
        
        /// The grid line's style
        public var lineStyle: LineStyle = .solid;
        
        /// The grid' line's width
        public var width: CGFloat = 0.33;
    }
    
    /// Properties used in the drawing of tooltips
    public struct Tooltip {
        /// The tooltip's arrow
        public var arrow: TooltipArrow = TooltipArrow();
        
        /// The tooltip's background color
        public var backgroundColor: UIColor = .systemBackground;
        
        /// The tooltip's border
        public var border: Border = Border();
        
        /// The tooltip's corner radii
        public var cornerRadii: CornerRadii = CornerRadii(bottomLeft: 4.0, bottomRight: 4.0, topLeft: 4.0, topRight: 4.0);
        
        /// The title label's color
        public var titleColor: UIColor = .label;
        
        /// The title label's font
        public var titleFont: UIFont = UIFont.preferredFont(forTextStyle: .body);
        
        /// Spacing applied to the left, top, right and bottom edges of the tooltip as well as between the labels
        public var tooltipSpacing: TooltipSpacing = TooltipSpacing(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0, middle: .zero);
        
        /// The value label's color
        public var valueColor: UIColor = .secondaryLabel;
        
        /// The value label's font
        public var valueFont: UIFont = UIFont.preferredFont(forTextStyle: .subheadline);
    }
    
    /// Properties used in drawing the tooltip's arrow
    public struct TooltipArrow {
        /// The tooltip arrow's background color
        public var backgroundColor: UIColor = UIColor.systemFill.withAlphaComponent(0.35);
        
        /// The tooltip arrow's height
        public var height: CGFloat = 16.0;
    }
    
    /// Corner radius values for each of the four corners
    public struct TooltipSpacing {
        /// The top edge spacing value
        public var top: CGFloat = .zero;
        
        /// The left edge spacing value
        public var left: CGFloat = .zero;
        
        /// The bottom edge spacing value
        public var bottom: CGFloat = .zero;
        
        /// The right edge spacing value
        public var right: CGFloat = .zero;
        
        /// The middle spacing value
        public var middle: CGFloat = .zero;

        // Create the initializer
        public init(top floatTop: CGFloat = .zero, left floatLeft: CGFloat = .zero, bottom floatBottom: CGFloat = .zero, right floatRight: CGFloat = .zero, middle floatMiddle: CGFloat = .zero) {
            self.top = floatTop;
            self.left = floatLeft;
            self.bottom = floatBottom;
            self.right = floatRight;
            self.middle = floatMiddle;
        }
    }
    
    // MARK: - Calculations
    
    /// Calculates the incriment (i.e. how many pixels make up floatInterval)
    internal static func calculateIncriment(in collectionView: UICollectionView, with arrayPayload: [Double]?) -> CGFloat {
        // Find the max value in the payload
        let doubleMaxValue: Double = self.payloadMax(for: arrayPayload);
        
        // Find the min value in the payload
        let doubleMinValue: Double = self.payloadMin(for: arrayPayload);
        
        // Calculate the range between the min and max values
        let doubleRange: Double = self.calculateRange(maxValue: doubleMaxValue, minValue: doubleMinValue);
        
        // Calculate the interval for this range
        let floatInterval: CGFloat = ChartCore.calculateInterval(maxValue: doubleMaxValue, minValue: doubleMinValue);
        
        // Calculate the incriments
        let floatIncriment: CGFloat = (collectionView.contentSize.height / CGFloat(doubleRange)) * floatInterval;
        let floatIncrimentEmpty: CGFloat = (collectionView.contentSize.height / CGFloat(5)) * floatInterval;
        
        return (arrayPayload?.count ?? 0) > 0 ? floatIncriment : floatIncrimentEmpty;
    }
    
    /// Calculates the interval / step that will be used while charting
    internal static func calculateInterval(maxValue doubleMaxValue: Double, minValue doubleMinValue: Double) -> CGFloat {
        // Calculation steps
        enum Step {
            case step1;
            case step2;
            case step3;
        }
        
        // Setup any required variables
        var doubleInterval: Double = 1.0;
        var doubleMultiplier: Double = Double.zero;
        var step: Step = .step1;
        
        // Calculate the range between the min and max values
        let doubleRange: Double = self.calculateRange(maxValue: doubleMaxValue, minValue: doubleMinValue);
        
        // Check to see if we should return a pre-determined range
        if (doubleRange <= 10) {
            return 1.0;
        } else {
               // Look through interval calculation
               repeat {
                   // Check to see which step is active
                   if (step == .step1) {
                       // Update the multiplier
                       doubleMultiplier = 2.5;
                       
                       // Incriment the step
                       step = .step2;
                   } else if (step == .step2) {
                       // Update the multiplier
                       doubleMultiplier = 2.0;
                       
                       // Incriment the step
                       step = .step3;
                   } else if (step == .step3) {
                       // Update the multiplier
                       doubleMultiplier = 2.0;
                       
                       // Incriment the step
                       step = .step1;
                  }
                   
                   // Update doubleInterval
                   doubleInterval = doubleInterval * doubleMultiplier;
               } while doubleInterval < (doubleRange / 5)
               
               return CGFloat(doubleInterval);
        }
    }
    
    /// Calculate the location of the point on the y-axis
    internal static func calculatePointLocationY(in collectionView: UICollectionView, with arrayPayload: [Double]?, at indexPath: IndexPath) -> CGFloat {
        // Retreive the height of the collection view's content view
        let floatHeight: CGFloat = collectionView.contentSize.height
        
        // Retreive the payload for this indexPath
        let doublePayload: Double? = arrayPayload?[indexPath.row];
        
        // Calculate the range between the min and max values
        let doubleRange: Double = self.calculateRange(for: arrayPayload);
        
        // Calculate the value incriment per pixel
        let floatValuePerPixel: CGFloat = floatHeight / CGFloat(doubleRange);
        
        // Calculate the location of the point on the y-axis
        let floatLocationY: CGFloat = CGFloat(doublePayload ?? 0) * floatValuePerPixel;
        
        return floatLocationY;
    }
    
    /// Calculates the range of a payload
    internal static func calculateRange(for arrayPayload: [Double]?) -> Double {
        // Find the max value in the payload
        let doubleMaxValue: Double = self.payloadMax(for: arrayPayload);
        
        // Find the min value in the payload
        let doubleMinValue: Double = self.payloadMin(for: arrayPayload);
        
        // Calculate the range between the min and max values
        let doubleRange: Double = self.calculateRange(maxValue: doubleMaxValue, minValue: doubleMinValue);
        
        return doubleRange;
    }
    
    /// Calculates the range between two values
    internal static func calculateRange(maxValue doubleMaxValue: Double, minValue doubleMinValue: Double) -> Double {
        // Calculate the range between the min and max values
        let doubleRange: Double = abs(doubleMaxValue) + abs(doubleMinValue);
        
        return doubleRange;
    }
    
    /// Calculates the location of the zero axis grid line for a UICollectionView or a UICollectionViewCell
    internal static func calculateZeroAxisLocation(for object: AnyObject, with arrayPayload: [Double]?) -> CGFloat {
        // Calculate floatHeight
        var floatHeight: CGFloat {
            // Check to see which object is requesting the zero axis height
            if (object.isKind(of: UICollectionView.classForCoder())) {
                return (object as! UICollectionView).contentSize.height;
            } else if (object.isKind(of: UICollectionViewCell.classForCoder())) {
                return (object as! UICollectionViewCell).frame.size.height;
            }
            
            return CGFloat.zero;
        };
        
        // Find the max value in the payload
        let doubleMaxValue: Double = self.payloadMax(for: arrayPayload);
        
        // Find the min value in the payload
        let doubleMinValue: Double = self.payloadMin(for: arrayPayload);
        
        // Calculate the range between the min and max values
        let doubleRange: Double = self.calculateRange(maxValue: doubleMaxValue, minValue: doubleMinValue);
        
        // Calculate the value incriment per pixel
        let floatValuePerPixel: CGFloat = floatHeight / CGFloat(doubleRange);
        
        // Check to see what zero axis location should be returned
        if (doubleMinValue >= 0) {
            // doubleMinValue is greater than or equal to zero, so the zero axis should be at the bottom of the cell
            return floatHeight;
        } else if (doubleMaxValue <= 0) {
            // doubleMinValue is less than or equal to zero, so the zero axis should be at the top of the cell
            return CGFloat.zero;
        } else {
            // Calculate the location of the zero axis
            return CGFloat(doubleMaxValue) * floatValuePerPixel;
        }
    }
    
    /// Finds the maximum value in the payload
    internal static func payloadMax(for arrayPayload: [Double]?) -> Double {
        // Find the max value in the payload
        let doubleMaxValue: Double = arrayPayload?.map({ $0 }).max() ?? 0;
        
        return doubleMaxValue;
    }
    
    /// Finds the minimum value in the payload
    internal static func payloadMin(for arrayPayload: [Double]?) -> Double {
        // Find the min value in the payload
        let doubleMinValue: Double = arrayPayload?.map({ $0 }).min() ?? 0;
        
        return doubleMinValue;
    }
    
    // MARK: - Demo Functions
    
    /// Creates a demo payload
    public static func generateTestPayload(numberOfDataPoints intNumberOfDataPoints: Int, maxValue: Double, minValue: Double, valueType: ValueType) -> [Double] {
        // Setup any required variables
        var arrayPayload: [Double] = [];
        var intIterations: Int = 0;
        
        // Check to make sure that a non-zero number of data points has been requested
        if (intNumberOfDataPoints > 0) {
            // Generate the payload
            repeat {
                // Check to see if valueType is Double or Integer
                if (valueType == .double) {
                    // Calculate the value
                    let doubleValue: Double = Double.random(in: minValue ... maxValue);
                    let divisor = pow(10.0, Double(2));
                    let doubleValueRounded: Double = (doubleValue * divisor).rounded() / divisor;

                    // Add the value to the payload
                    arrayPayload.append(doubleValueRounded);
                } else if (valueType == .integer) {
                    // Calculate the value
                    let intValue: Int = Int.random(in: Int(minValue) ... Int(maxValue));

                    // Add the value to the payload
                    arrayPayload.append(Double(intValue));
                }

                // Incriment intIterations
                intIterations += 1;
            } while intIterations < intNumberOfDataPoints;
        }
        
        return arrayPayload;
    }
    
    // MARK: - Colors
    
    /// Blends multiple UIColors together into a new UIColor
    internal static func blendColors(colors: [UIColor]) -> UIColor {
        // Calculate the average RGBA values
        let floatRed: CGFloat = colors.reduce(0) { $0 + CIColor(color: $1).red } / CGFloat(colors.count);
        let floatGreen: CGFloat = colors.reduce(0) { $0 + CIColor(color: $1).green } / CGFloat(colors.count);
        let floatBlue: CGFloat = colors.reduce(0) { $0 + CIColor(color: $1).blue } / CGFloat(colors.count);
        let floatAlpha: CGFloat = colors.reduce(0) { $0 + CIColor(color: $1).alpha } / CGFloat(colors.count);
        
        return UIColor(red: floatRed, green: floatGreen, blue: floatBlue, alpha: floatAlpha);
    }
    
    // MARK: - Drawing
    
    /// Draw a circle begining at a point, with a specified circumference, border color, border width and fill color
    internal static func drawCircle(from pointStart: CGPoint, circumference floatCircumference: CGFloat, borderColor colorBorder: UIColor, borderWidth floatBorderWidth: CGFloat, fillColor colorFill: UIColor, in view: UIView?) {
        // Create a mutable path
        let path: CGMutablePath = CGMutablePath();
        
        //Add the ellipse
        path.addEllipse(in: CGRect(x: pointStart.x - (floatCircumference / 2), y: pointStart.y - (floatCircumference / 2), width: floatCircumference, height: floatCircumference));
        
        // Close the path
        path.closeSubpath();
        
        // Configure the CAShapeLayer
        let layer: CAShapeLayer = CAShapeLayer();
        layer.path = path;
        layer.fillColor = colorFill.cgColor;
        layer.lineWidth = floatBorderWidth;
        layer.strokeColor = colorBorder.cgColor;

        // Add the layer to the view
        view?.layer.addSublayer(layer);
    }
    
    /// Draws a line from one point to another
    internal static func drawLine(from pointStart: CGPoint, to pointEnd: CGPoint, color: UIColor, style lineStyle: LineStyle = .solid, invertLineStyle boolInvertLineStyle: Bool = false, width floatWidth: CGFloat, in view: UIView?) {
        // Configure the UIBezierPath
        let path: UIBezierPath = UIBezierPath();
        path.move(to: pointStart);
        path.addLine(to: pointEnd);
        
        // Configure the CAShapeLayer
        let layer: CAShapeLayer = CAShapeLayer();
        layer.path = path.cgPath;
        layer.lineWidth = floatWidth;
        layer.strokeColor = color.cgColor;
        
        // Check to see which line style was requested
        if (lineStyle == .dashed) {
            // Dashed line (ex: ----    ----    ----)
            layer.lineDashPattern = [4, 4];
            
            // Check to see if we should invert the line style
            if (boolInvertLineStyle) {
                // Invert the line style
                layer.lineDashPhase = 4;
            }
        } else if (lineStyle == .dashedShort) {
            // Dashed line (ex: --  --  --  --  --  )
            layer.lineDashPattern = [2, 2];
            
            // Check to see if we should invert the line style
            if (boolInvertLineStyle) {
                // Invert the line style
                layer.lineDashPhase = 2;
            }
        } else if (lineStyle == .dotted) {
            // Dotted line (ex: - - - - - - - - - - )
            layer.lineDashPattern = [1, 1];
            
            // Check to see if we should invert the line style
            if (boolInvertLineStyle) {
                // Invert the line style
                layer.lineDashPhase = 1;
            }
        } else  {
            // Solid line (ex: ------------------- )
            layer.lineDashPattern = [1, 0];
        }

        // Add the layer to the view
        view?.layer.addSublayer(layer);
    }
    
    /// Draw a rectangle begining at a point, with a specified width, height, color and radii for each corner
    internal static func drawRectangle(from pointStart: CGPoint, width floatWidth: CGFloat, height floatHeight: CGFloat, cornerRadii: CornerRadii, color: UIColor, in view: UIView?) {
        // Check to see if any corner radii need to be adjusted to compensate for a bar whose height is less than that of any of the radii
        let floatCornerRadiusBottomLeft: CGFloat = (abs(floatHeight) / 2) >= cornerRadii.bottomLeft ? cornerRadii.bottomLeft : (abs(floatHeight) / 2);
        let floatCornerRadiusBottomRight: CGFloat = (abs(floatHeight) / 2) >= cornerRadii.bottomRight ? cornerRadii.bottomRight : (abs(floatHeight) / 2);
        let floatCornerRadiusTopLeft: CGFloat = (abs(floatHeight) / 2) >= cornerRadii.topLeft ? cornerRadii.topLeft : (abs(floatHeight) / 2);
        let floatCornerRadiusTopRight: CGFloat = (abs(floatHeight) / 2) >= cornerRadii.topRight ? cornerRadii.topRight : (abs(floatHeight) / 2);
        
        // Calculate the adjustments that will be used below when drawing the bar
        let floatAdjustmentBottomLeft: CGFloat = floatHeight > 0 ? floatCornerRadiusBottomLeft : floatCornerRadiusBottomLeft;
        let floatAdjustmentBottomRight: CGFloat = floatHeight > 0 ? -floatCornerRadiusBottomRight : floatCornerRadiusBottomRight;
        let floatAdjustmentTopLeft: CGFloat = floatHeight > 0 ? floatCornerRadiusTopLeft : -floatCornerRadiusTopLeft;
        let floatAdjustmentTopRight: CGFloat = floatHeight > 0 ? -floatCornerRadiusTopRight : -floatCornerRadiusTopRight;
        
        // Create a mutable path
        let path: CGMutablePath = CGMutablePath();
        
        // Check to see if the bar will appear above or below the zero axis
        if (floatHeight < 0) {
            // The bar will appear above the zero axis
            path.move(to: CGPoint(x: pointStart.x, y: pointStart.y + floatAdjustmentBottomLeft));
        } else {
            // The bar will appear below the zero axis
            path.move(to: CGPoint(x: pointStart.x, y: pointStart.y - floatAdjustmentBottomLeft));
        }
        
        // Add the bottom-left corner
        path.addArc(tangent1End: CGPoint(x: pointStart.x, y: pointStart.y),
                    tangent2End: CGPoint(x: pointStart.x + floatAdjustmentBottomLeft, y: pointStart.y),
                    radius: floatCornerRadiusBottomLeft);
        
        // Add the bottom-right corner
        path.addArc(tangent1End: CGPoint(x: (pointStart.x + floatWidth), y: pointStart.y),
                    tangent2End: CGPoint(x: pointStart.x + floatWidth, y: pointStart.y + floatAdjustmentBottomRight),
                    radius: floatCornerRadiusBottomRight);
        
        // Add the top-right corner
        path.addArc(tangent1End: CGPoint(x: pointStart.x + floatWidth, y: pointStart.y - floatHeight),
                    tangent2End: CGPoint(x: (pointStart.x + floatWidth) + floatAdjustmentTopRight, y: pointStart.y - floatHeight),
                    radius: floatCornerRadiusTopRight);
        
        // Add the top-left corner
        path.addArc(tangent1End: CGPoint(x: pointStart.x, y: pointStart.y - floatHeight),
                    tangent2End: CGPoint(x: pointStart.x, y: (pointStart.y - floatHeight) + floatAdjustmentTopLeft),
                    radius: floatCornerRadiusTopLeft);
        
        // Close the path
        path.closeSubpath();
        
        // Configure the CAShapeLayer
        let layer: CAShapeLayer = CAShapeLayer();
        layer.path = path;
        layer.fillColor = color.cgColor;

        // Add the layer to the view
        view?.layer.addSublayer(layer);
    };
    
    /// Draws a shape from a series of supplied points
    internal static func drawShape(points arrayPoints: [CGPoint], color: UIColor, in view: UIView?) {
        // Create a mutable path
        let path: CGMutablePath = CGMutablePath();
        
        // Move the path to the start coordinates
        path.move(to: arrayPoints.first ?? CGPoint.zero);
        
        // Iterate through each point in the array of points
        for point: CGPoint in arrayPoints {
            // Add a line to the next point
            path.addLine(to: point);
        }
        
        // Close the path
        path.closeSubpath();
        
        // Configure the CAShapeLayer
        let layer: CAShapeLayer = CAShapeLayer();
        layer.path = path;
        layer.fillColor = color.cgColor;

        // Add the layer to the view
        view?.layer.addSublayer(layer);
    }
    
    /// Draws text at the specified point
    internal static func drawText(from pointStart: CGPoint, direction textDrawingDirection: TextDrawingDirection, text stringText: String, color: UIColor, font: UIFont, in view: UIView?) {
        // Configure the paragraph style
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle();
        paragraphStyle.alignment = .center;
        
        // Configure the tooltip's title label
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: stringText);
        attributedString.addAttributes([.font: font,
                                        .foregroundColor: color,
                                        .paragraphStyle: paragraphStyle],
                                       range: NSRange(location: .zero, length: stringText.count));
        
        // Configure the CATextLayer
        let layer: CATextLayer = CATextLayer();
        layer.contentsScale = UIScreen.main.scale;
        layer.frame = CGRect(x: pointStart.x,
                             y: pointStart.y,
                             width: attributedString.size().width,
                             height: attributedString.size().height)
        layer.string = attributedString;
        
        // Check to see if any special TextDrawingDirection is specified (LeftToRight needs not adjustment)
        if (textDrawingDirection == .bottomToTop) {
            // Adjust the layer's postion
            layer.position = CGPoint(x: attributedString.size().height / 2, y: attributedString.size().width / 2);
            
            // Apply the rotation
            layer.transform = CATransform3DMakeRotation(.pi * -90 / 180, 0.0, 0.0, 1.0);
        } else if (textDrawingDirection == .topToBottom) {
            // Adjust the layer's postion
            layer.position = CGPoint(x: attributedString.size().height / 2, y: attributedString.size().width / 2);
            
            // Apply the rotation
            layer.transform = CATransform3DMakeRotation(.pi * 90 / 180, 0.0, 0.0, 1.0);
        }
        
        // Add the layer to the view
        view?.layer.addSublayer(layer);
    }
    
    /// Draws the tooltip and an arrow pointing to it's point of origin
    @discardableResult internal static func drawTooltip(from pointStart: CGPoint, direction arrayTooltipDirection: [TooltipDirection], title stringTitle: String?, value stringValue: String?, settings tooltipSettings: Tooltip, in view: UIView?) -> CGRect {
        // Configure the paragraph style
        let paragraphStyle: NSMutableParagraphStyle = NSMutableParagraphStyle();
        paragraphStyle.alignment = .center;
        
        // Configure the tooltip's title label
        let attributedStringTitle: NSMutableAttributedString = NSMutableAttributedString(string: stringTitle ?? "");
        attributedStringTitle.addAttributes([.font: tooltipSettings.titleFont,
                                             .foregroundColor: tooltipSettings.titleColor,
                                             .paragraphStyle: paragraphStyle],
                                            range: NSRange(location: .zero, length: stringTitle?.count ?? 0));
        
        // Configure the tooltip's value label
        let attributedStringValue: NSMutableAttributedString = NSMutableAttributedString(string: stringValue ?? "");
        attributedStringValue.addAttributes([.font: tooltipSettings.valueFont,
                                             .foregroundColor: tooltipSettings.valueColor,
                                             .paragraphStyle: paragraphStyle],
                                            range: NSRange(location: .zero, length: stringValue?.count ?? 0));
        
        // Calculate the width and the height of the tooltip
        let floatWidth: CGFloat = tooltipSettings.tooltipSpacing.left + (attributedStringTitle.size().width > attributedStringValue.size().width ? attributedStringTitle.size().width : attributedStringValue.size().width) + tooltipSettings.tooltipSpacing.right;
        let floatHeight: CGFloat = tooltipSettings.tooltipSpacing.top + attributedStringTitle.size().height + tooltipSettings.tooltipSpacing.middle + attributedStringValue.size().height + tooltipSettings.tooltipSpacing.bottom;
        
        // The height of the tooltip's arrow
        var floatTooltipArrowHeight: CGFloat {
            // Check to see what direction the tooltip will open
            if (arrayTooltipDirection.contains(.down)) {
                return tooltipSettings.arrow.height;
            } else if (arrayTooltipDirection.contains(.up)) {
                return -tooltipSettings.arrow.height;
            } else {
                return tooltipSettings.arrow.height;
            }
        }
        
        // The X-Axis start point for the tooltip's arrow
        var floatPointStartArrowX: CGFloat {
            return pointStart.x;
        };
        
        // The Y-Axis start point for the tooltip's arrow
        var floatPointStartArrowY: CGFloat {
            return pointStart.y;
        }
        
        // The X-Axis start point for the tooltip
        var floatPointStartTooltipX: CGFloat {
            // Check to see what direction the tooltip will open
            if (arrayTooltipDirection.contains(.left)) {
                return pointStart.x - (floatWidth / 2);
            } else if (arrayTooltipDirection.contains(.right)) {
                return pointStart.x + (floatWidth / 2);
            } else {
                return pointStart.x;
            }
        }
        
        // The Y-Axis start point for the tooltip
        var floatPointStartTooltipY: CGFloat {
            // Check to see what direction the tooltip will open
            if (arrayTooltipDirection.contains(.down)) {
                return pointStart.y + floatHeight + floatTooltipArrowHeight;
            } else if (arrayTooltipDirection.contains(.up)) {
                return pointStart.y + floatTooltipArrowHeight;
            } else {
                return pointStart.y;
            }
        };
        
        // The left-side corner that the tooltip's arrow will draw to
        var floatTooltipArrowCornerLeft: CGFloat {
            // Check to see what direction the tooltip will open
            if (arrayTooltipDirection.contains(.down)) {
                return tooltipSettings.cornerRadii.topLeft;
            } else if (arrayTooltipDirection.contains(.up)) {
                return -tooltipSettings.cornerRadii.bottomLeft;
            } else {
                return tooltipSettings.cornerRadii.topLeft;
            }
        }
        
        // The right-side corner that the tooltip's arrow will draw to
        var floatTooltipArrowCornerRight: CGFloat {
            // Check to see what direction the tooltip will open
            if (arrayTooltipDirection.contains(.down)) {
                return tooltipSettings.cornerRadii.topRight;
            } else if (arrayTooltipDirection.contains(.up)) {
                return -tooltipSettings.cornerRadii.bottomRight;
            } else {
                return tooltipSettings.cornerRadii.topRight;
            }
        }
        
        // The width of the title and value labels
        var floatTooltipTitleValueWidth: CGFloat {
            return attributedStringTitle.size().width > attributedStringValue.size().width ? attributedStringTitle.size().width : attributedStringValue.size().width;
        }
        
        // The X-Axis start point for the tooltip's title label
        var floatPointStartTooltipTitleX: CGFloat {
            return floatPointStartTooltipX - (floatWidth / 2) + tooltipSettings.tooltipSpacing.left;
        }
        
        // The Y-Axis start point for the tooltip's title label
        var floatPointStartTooltipTitleY: CGFloat {
            return floatPointStartTooltipY - tooltipSettings.tooltipSpacing.bottom - attributedStringValue.size().height - tooltipSettings.tooltipSpacing.middle - attributedStringTitle.size().height;
        }
        
        // The X-Axis start point for the tooltip's value label
        var floatPointStartTooltipValueX: CGFloat {
            return floatPointStartTooltipX - (floatWidth / 2) + tooltipSettings.tooltipSpacing.left;
        }
        
        // The Y-Axis start point for the tooltip's value label
        var floatPointStartTooltipValueY: CGFloat {
            return floatPointStartTooltipY - tooltipSettings.tooltipSpacing.bottom - attributedStringValue.size().height;
        }
        
        // MARK: Draw the tooltip's arrow
        
        // Create a mutable path
        let pathTooltipArrow: CGMutablePath = CGMutablePath();
        
        // Move the path to the start coordinates
        pathTooltipArrow.move(to: CGPoint(x: floatPointStartArrowX, y: floatPointStartArrowY));
        
        // Add a line to the bottom-right corner
        pathTooltipArrow.addLine(to: CGPoint(x: (floatPointStartTooltipX + (floatWidth / 2)), y: floatPointStartArrowY + floatTooltipArrowHeight + floatTooltipArrowCornerRight));
        
        // Add a line to the bottom-left corner
        pathTooltipArrow.addLine(to: CGPoint(x: (floatPointStartTooltipX - (floatWidth / 2)), y: floatPointStartArrowY + floatTooltipArrowHeight + floatTooltipArrowCornerLeft));
        
        // Close the path
        pathTooltipArrow.closeSubpath();
        
        // Configure the CAShapeLayer
        let layerArrow: CAShapeLayer = CAShapeLayer();
        layerArrow.name = "tooltipArrow";
        layerArrow.path = pathTooltipArrow;
        layerArrow.fillColor = tooltipSettings.arrow.backgroundColor.cgColor;

        // Add the layer to the view
        view?.layer.addSublayer(layerArrow);
        
        // MARK: Draw the tooltip
        
        // Create a mutable path
        let pathTooltip: CGMutablePath = CGMutablePath();
        
        // Move the path to the start coordinates
        pathTooltip.move(to: CGPoint(x: floatPointStartTooltipX, y: floatPointStartTooltipY));
        
        // Add the bottom-right corner
        pathTooltip.addArc(tangent1End: CGPoint(x: (floatPointStartTooltipX + (floatWidth / 2)), y: floatPointStartTooltipY),
                    tangent2End: CGPoint(x: (floatPointStartTooltipX + (floatWidth / 2)), y: floatPointStartTooltipY - tooltipSettings.cornerRadii.bottomRight),
                    radius: tooltipSettings.cornerRadii.bottomRight);

        // Add the top-right corner
        pathTooltip.addArc(tangent1End: CGPoint(x: (floatPointStartTooltipX + (floatWidth / 2)), y: (floatPointStartTooltipY - floatHeight)),
                    tangent2End: CGPoint(x: (floatPointStartTooltipX + (floatWidth / 2)) - tooltipSettings.cornerRadii.topRight, y: (floatPointStartTooltipY - floatHeight)),
                    radius: tooltipSettings.cornerRadii.topRight);

        // Add the top-left corner
        pathTooltip.addArc(tangent1End: CGPoint(x: (floatPointStartTooltipX - (floatWidth / 2)), y: (floatPointStartTooltipY - floatHeight)),
                    tangent2End: CGPoint(x: (floatPointStartTooltipX - (floatWidth / 2)), y: (floatPointStartTooltipY - floatHeight) + tooltipSettings.cornerRadii.topLeft),
                    radius: tooltipSettings.cornerRadii.topLeft);

        // Add the bottom-left corner
        pathTooltip.addArc(tangent1End: CGPoint(x: (floatPointStartTooltipX - (floatWidth / 2)), y: floatPointStartTooltipY),
                    tangent2End: CGPoint(x: (floatPointStartTooltipX - (floatWidth / 2)) + tooltipSettings.cornerRadii.bottomLeft, y: floatPointStartTooltipY),
                    radius: tooltipSettings.cornerRadii.bottomLeft);
        
        // Close the path
        pathTooltip.closeSubpath();
        
        // Configure the CAShapeLayer
        let layerTooltip: CAShapeLayer = CAShapeLayer();
        layerTooltip.name = "tooltipBox";
        layerTooltip.path = pathTooltip;
        layerTooltip.fillColor = tooltipSettings.backgroundColor.cgColor;
        layerTooltip.lineWidth = tooltipSettings.border.width;
        layerTooltip.strokeColor = tooltipSettings.border.color.cgColor;
        
        // Add the layer to the view
        view?.layer.addSublayer(layerTooltip);
        
        // Configure the CATextLayer
        let layerTitle: CATextLayer = CATextLayer();
        layerTitle.contentsScale = UIScreen.main.scale;
        layerTitle.frame = CGRect(x: floatPointStartTooltipTitleX + ((floatTooltipTitleValueWidth - attributedStringTitle.size().width) / 2),
                                  y: floatPointStartTooltipTitleY,
                                  width: attributedStringTitle.size().width,
                                  height: attributedStringTitle.size().height);
        layerTitle.name = "tooltipTitle";
        layerTitle.string = attributedStringTitle;
        
        // Add the layer to the view
        view?.layer.addSublayer(layerTitle);
        
        // Configure the CATextLayer
        let layerValue: CATextLayer = CATextLayer();
        layerValue.contentsScale = UIScreen.main.scale;
        layerValue.frame = CGRect(x: floatPointStartTooltipValueX + ((floatTooltipTitleValueWidth - attributedStringValue.size().width) / 2),
                                  y: floatPointStartTooltipValueY,
                                  width: attributedStringValue.size().width,
                                  height: attributedStringValue.size().height);
        layerValue.name = "tooltipValue";
        layerValue.string = attributedStringValue;
        
        // Add the layer to the view
        view?.layer.addSublayer(layerValue);
        
        return pathTooltip.boundingBoxOfPath;
    }
    
    /// Removes the previous tooltip from the view
    internal static func removeTooltip(in view: UIView?) {
        // Filter out any layers with 'tooltip' in the name and remove them
        view?.layer.sublayers?.filter({ $0.name?.contains("tooltip") == true }).forEach({ $0.removeFromSuperlayer(); });
    }
}
