//
//  UITextField+Icons.swift
//  UITextField+Icons
//
//  Created by Jason Cox on 4/2/20.
//  Copyright © 2020 Jason Cox. All rights reserved.
//

import UIKit

protocol UITextFieldIconsDelegate
{
    func UITextFieldIconsLeadingIcon_Tap(sender: UITextField_Icons);
    func UITextFieldIconsTrailingIcon_Tap(sender: UITextField_Icons);
}

extension UITextFieldIconsDelegate
{
    func UITextFieldIconsLeadingIcon_Tap(sender: UITextField_Icons)
    {
    }
    
    func UITextFieldIconsTrailingIcon_Tap(sender: UITextField_Icons)
    {
    }
}

@IBDesignable class UITextField_Icons: UITextField {
    // MARK: - Delegates
    
    // Setup the delegate
    private var delegateIcon: UITextFieldIconsDelegate?;

    override var delegate: UITextFieldDelegate?
    {
        didSet
        {
            delegateIcon = self.delegate as? UITextFieldIconsDelegate;
        }
    }
    
    // MARK: - Enums
    
    private enum Side {
        case leading;
        case trailing;
    }
    
    // MARK: - Classes
    
    private class UIButtonAction: UIButton
    {
        var action: (() -> Void)? = nil;
    }
    
    // MARK: - Interface Builder Properties
    
    // MARK: Leading icon properties
    @IBInspectable internal var leadingColor: UIColor? {
        didSet {
            // Render the control
            self.renderControl();
        }
    };
    @IBInspectable internal var leadingIcon: UIImage? {
        didSet {
            // Render the control
            self.renderControl();
        }
    };
    internal var leadingTapAction: (() -> Void)? {
        didSet {
            // Render the control
            self.renderControl();
        }
    };
    
    // MARK: Trailing icon properties
    @IBInspectable internal var trailingColor: UIColor? {
        didSet {
            // Render the control
            self.renderControl();
        }
    };
    @IBInspectable internal var trailingIcon: UIImage? {
        didSet {
            // Render the control
            self.renderControl();
        }
    };
    internal var trailingTapAction: (() -> Void)? {
        didSet {
            // Render the control
            self.renderControl();
        }
    };
    
    // MARK: Icon Spacing
    @IBInspectable internal var iconSpacingLeft: CGFloat = 8 {
        didSet {
            // Render the control
            self.renderControl();
        }
    };
    @IBInspectable internal var iconSpacingRight: CGFloat = 8 {
           didSet {
               // Render the control
               self.renderControl();
           }
       };
    
    // MARK: - Control
    
    /// Renders the control
    private func renderControl() {
        // Check to see if a leading icon was specified
        if (self.leadingIcon != nil) {
            // Set the leading icon
            self.setIcon(side: .leading, image: self.leadingIcon, color: self.leadingColor, onTapAction: self.leadingTapAction);
        } else {
            // Reset the left view to nil
            self.leftView = nil;
        }
        
        // Check to see if a trailing icon was specified
        if (self.trailingIcon != nil) {
            // Set the trailing icon
            self.setIcon(side: .trailing, image: self.trailingIcon, color: self.trailingColor, onTapAction: self.trailingTapAction);
        } else {
            // Reset the right view to nil
            self.rightView = nil;
        }
        
        // Indicate that the view needs laid out
        self.setNeedsLayout();
    }
    
    // MARK: - General Functions
    
    /// Executes a supplied action
    @objc private func action(sender: UIButtonAction)
    {
        // Check to see if an action was supplied
        if (sender.action != nil)
        {
            // Execute the action
            sender.action!();
        }
    }
    
    /// Adds an icon to the specified side with the specified color and tap action
    private func setIcon(side: Side, image: UIImage?, color: UIColor?, onTapAction: (() -> Void)? = nil) {
        // Setup the button
        let button: UIButtonAction = UIButtonAction(frame: CGRect(x: CGFloat.zero,
                                                      y: CGFloat.zero,
                                                      width: self.iconSpacingLeft + (image?.size.width ?? CGFloat.zero) + self.iconSpacingRight,
                                                      height: self.frame.size.height));
        
        // Check to see if an action was supplied
        if (onTapAction != nil) {
            // Add the action
            button.action = onTapAction;
        } else {
            // Add the delegate callback
            button.action = {
                // Check to see which icon was tapped
                if (side == .leading) {
                    // Execute the delegate callback for the leading icon
                    self.delegateIcon?.UITextFieldIconsLeadingIcon_Tap(sender: self);
                } else {
                    // Execute the delegate callback for the trailing icon
                    self.delegateIcon?.UITextFieldIconsTrailingIcon_Tap(sender: self);
                }
            }
        }
        
        // Configure the button
        button.addTarget(self, action: #selector(action(sender:)), for: .touchUpInside);
        button.adjustsImageWhenHighlighted = onTapAction != nil ? true : false;
        
        button.contentEdgeInsets = UIEdgeInsets(top: 0,
                                                left: self.iconSpacingLeft,
                                                bottom: 0,
                                                right: self.iconSpacingRight);
        button.setImage(image, for: .normal);
        button.showsTouchWhenHighlighted = false;
        button.tintColor = color ?? .placeholderText;
        
        // Setup the container view
        let viewContainer: UIView = UIView(frame: CGRect(x: CGFloat.zero,
                                                         y: CGFloat.zero,
                                                         width: button.frame.size.width,
                                                         height: button.frame.size.height));
        
        // Add the button to the container view
        viewContainer.addSubview(button);
        
        // Check to see which side the icon should be place on
        if (side == .leading) {
            // Add the icon to the leading side
            self.leftView = viewContainer;
            self.leftViewMode = .always;
        } else if (side == .trailing) {
            // Add the icon to the trailing side
            self.rightView = viewContainer;
            self.rightViewMode = .always;
        }
    }
}
