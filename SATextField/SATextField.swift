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
    var slidesPlaceholder = true
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


private extension UIView {
    /**
        Sets the leading, top, trailing, and bottom constraints with the given amounts
        of this view to its parent view, effectively "pinning" it into its parent.
        Custom offsets are optional; their values default to 0.0.
        
        Makes calls to `layoutIfNeeded` and `updateConstraints` after adding the constraints.
        
        - parameter leading: Leading space (optional).
        - parameter top: Top space (optional).
        - parameter trailing: Trailing space (optional).
        - parameter bottom: Bottom space (optional).
    */
    private func pinToParentView(leading: CGFloat = 0.0, top: CGFloat = 0.0, trailing: CGFloat = 0.0, bottom: CGFloat = 0.0) {
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: self.superview, attribute: .Top, multiplier: 1.0, constant: top))
        constraints.append(NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: self.superview, attribute: .Leading, multiplier: 1.0, constant: leading))
        constraints.append(NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: self.superview, attribute: .Bottom, multiplier: 1.0, constant: bottom))
        constraints.append(NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: self.superview, attribute: .Trailing, multiplier: 1.0, constant: trailing))
        
        self.superview?.addConstraints(constraints)
        self.superview?.setNeedsDisplay()
    }
    
    /**
        Sets the anchor point. Used for performing animations around points other than the center.

        anchorPoint The desired anchor point of the view.
    */
    private func setAnchorPoint(anchorPoint: CGPoint) {
        var newPoint = CGPointMake(self.bounds.size.width * anchorPoint.x, self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(self.bounds.size.width * self.layer.anchorPoint.x, self.bounds.size.height * self.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, self.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, self.transform)
        
        var position = self.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
}
