//
//  SATextField.swift
//  SATextField
//
//  Created by Stefan Arambasich on 9/3/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

/**
    Customiz-ed/-able version of `UITextField`.

    Features:
    - Sliding placeholder label
*/
@IBDesignable
class SATextField: UITextField {
    /**
        Subviews belonging to the text view.
    */
    enum ViewIdentifiers: Int {
        case SlidePlaceholderLabel = 1
    }
    
    /// Use this instead of `placeholder` for the custom placeholder
    /// Setting a value to this creates a `UILabel` and adds it as a sub-
    /// view of this text view. If nil, removes the aformentioned label.
    @IBInspectable var placeholderText: String? {
        didSet {
            configurePlaceholder()
        }
    }
    /// Use this to change the text color of the placeholder for the default
    /// state. Defaults to UIColor.grayColor().
    @IBInspectable var placeholderTextColor: UIColor = UIColor.grayColor() {
        didSet {
            configurePlaceholder()
        }
    }
    /// Use this to change the text color of the placeholder for the slid
    /// state. Defaults to UIColor.grayColor().
    @IBInspectable var placeholderTextColorFocused: UIColor = UIColor.whiteColor() {
        didSet {
            configurePlaceholder()
        }
    }
    /// Whether to slide the placeholder text from inside the text field
    /// to the top of the text field.
    @IBInspectable var slidesPlaceholder: Bool = true
    /// How long to animate the placeholder slide
    var slideAnimationDuration: NSTimeInterval = 0.15
    /// slidingPlaceholderFontSizePercentage
    var slidingPlaceholderFontSizePercentage: CGFloat = 0.85
    /// An X-offset for the placeholder text from its bounds
    var placeholderOffsetXDefault: CGFloat = 0.0
    /// An X-offset for the placeholder while slid upward
    var placeholderOffsetXSlid: CGFloat = 0.0
    /// An Y-offset for the placeholder text from its bounds
    var placeholderOffsetYDefault: CGFloat = 0.0
    /// An Y-offset for the placeholder while slid upward
    var placeholderOffsetYSlid: CGFloat = 0.0
    
    /// Hook invoked to customize the placeholder when slid
    var customizationsWhileSliding: ((UILabel) -> Void)?
    /// Hook invoked to customize the placeholder when not slid
    var customizationsForDefault: ((UILabel) -> Void)?
    
    /// Gets the placeholder's rectangle (wrapper for `placeholderRectForBounds:`)
    var placeholderRect: CGRect {
        return placeholderRectForBounds(bounds)
    }
    
    /// Returns the placeholder label if it exists
    var placeholderLabel: UILabel? {
        let svs = subviews 
        if let l = svs.filter({ $0.tag == ViewIdentifiers.SlidePlaceholderLabel.rawValue }).first as? UILabel {
            return l
        }
        
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        selfInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selfInit()
    }
    
    /**
        Single point of initialization for `self`.
    */
    private func selfInit() {
        addTarget(self, action: "textFieldDidBeginEditing:", forControlEvents: UIControlEvents.EditingDidBegin)
        addTarget(self, action: "textFieldDidEndEditing:", forControlEvents: UIControlEvents.EditingDidEnd)
        addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        configurePlaceholder()
    }
    
    /**
        Configures the placeholder relative to the status of the 
        `placeholderText` variable.
    */
    private func configurePlaceholder() {
        if let t = placeholderText where !t.isEmpty {
            let l: UILabel
            if let p = placeholderLabel {
                l = p
            } else {
                l = UILabel(frame: placeholderRect)
                l.tag = ViewIdentifiers.SlidePlaceholderLabel.rawValue
                l.translatesAutoresizingMaskIntoConstraints = false
                addSubview(l)
                let constraints = [
                    NSLayoutConstraint(item: l, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Leading, multiplier: 1.0, constant: placeholderOffsetXDefault),
                    NSLayoutConstraint(item: l, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: placeholderOffsetYDefault),
                ]
                addConstraints(constraints)
                
                placeholderOffsetYSlid = placeholderOffsetYDefault - l.frame.height
            }
            l.text = placeholderText
            l.font = font
            l.textColor = placeholderTextColor
            l.hidden = false
        } else {
            placeholderLabel?.removeFromSuperview()
        }
    }
    
    /// Finds the leading constraint of the `UILabel` of the sliding placeholder
    var slidingPlaceholderLeadingConstraint: NSLayoutConstraint! {
        if let c = constraints.filter({ (item) -> Bool in
            if let l = item.firstItem as? UILabel where l.tag == ViewIdentifiers.SlidePlaceholderLabel.rawValue && item.secondAttribute == NSLayoutAttribute.Leading {
                return true
            }
            
            return false
        }).first {
            return c
        }
        
        assertionFailure("You cannot call this before adding the label's constraints to the subview.")
        return nil
    }
    
    /// Finds the center-Y constraint of the `UILabel` of the sliding placeholder
    var slidingPlaceholderCenterYConstraint: NSLayoutConstraint {
        if let c = constraints.filter({ (item) -> Bool in
            if let l = item.firstItem as? UILabel where l.tag == ViewIdentifiers.SlidePlaceholderLabel.rawValue && item.secondAttribute == NSLayoutAttribute.CenterY {
                return true
            }
            
            return false
        }).first {
            return c
        }
        
        assertionFailure("You cannot call this before adding the label to the subview.")
        return NSLayoutConstraint()
    }
    
    /**
        Moves and sets the sldiing holder into the position it should be given the text field's state.
    
        - parameter animated: Whether to animate the transition. Defaults to `true`.
    */
    func setSlidingPlaceholder(animated: Bool = true) {
        if let p = placeholderLabel {
            if slidesPlaceholder {
                if !isFirstResponder() && (text == nil || text!.isEmpty) {
                    p.setAnchorPoint(CGPoint(x: 0.5, y: 0.5))
                    let setForInner = { () -> Void in
                        self.slidingPlaceholderLeadingConstraint.constant = self.placeholderOffsetXDefault
                        self.slidingPlaceholderCenterYConstraint.constant = self.placeholderOffsetYDefault
                        p.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)
                        p.textColor = self.placeholderTextColor
                        p.alpha = 1.0
                        self.customizationsForDefault?(p)
                        self.layoutIfNeeded()
                    }
                    
                    if animated {
                        UIView.animateWithDuration(slideAnimationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: setForInner, completion: nil)
                    } else {
                        setForInner()
                    }
                } else if slidingPlaceholderCenterYConstraint.constant != placeholderOffsetYSlid {
                    p.setAnchorPoint(CGPoint(x: 0.625, y: 0.5))
                    let setForOuter = { () -> Void in
                        self.slidingPlaceholderLeadingConstraint.constant = self.placeholderOffsetXSlid
                        self.slidingPlaceholderCenterYConstraint.constant = self.placeholderOffsetYSlid
                        p.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8)
                        p.textColor = self.isFirstResponder() ? self.placeholderTextColorFocused : self.placeholderTextColor
                        self.customizationsWhileSliding?(p)
                        self.layoutIfNeeded()
                    }
        
                    if animated {
                        UIView.animateWithDuration(slideAnimationDuration, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: setForOuter, completion: nil)
                    } else {
                        setForOuter()
                    }
                }
            } else {
                p.hidden = text != nil && !text!.isEmpty
            }
        }
    }
    
    func textFieldDidChange(textField: UITextField) {
        if let tf = textField as? SATextField where tf === self {
            tf.setSlidingPlaceholder()
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if let tf = textField as? SATextField where tf === self {
            tf.setSlidingPlaceholder()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let tf = textField as? SATextField where tf === self {
            tf.setSlidingPlaceholder()
        }
    }
}
