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
@IBDesignable open class SATextField: UITextField {

    /// Use this instead of `placeholder` for the custom placeholder
    /// Setting a value to this creates a `UILabel` and adds it as a sub-
    /// view of this text view. If nil, removes the aformentioned label.
    @IBInspectable open var placeholderText: String? {
        didSet {
            configurePlaceholderText()
        }
    }
    /// Use this to change the text color of the placeholder for the default
    /// state. Defaults to UIColor.grayColor().
    @IBInspectable open var placeholderTextColor: UIColor = UIColor.gray {
        didSet {
            configurePlaceholderText()
        }
    }
    /// Use this to change the text color of the placeholder for the slid
    /// state. Defaults to UIColor.grayColor().
    @IBInspectable open var placeholderTextColorFocused: UIColor = UIColor.white {
        didSet {
            configurePlaceholderText()
        }
    }
    /// Whether to slide the placeholder text from inside the text field
    /// to the top of the text field.
    @IBInspectable open var slidesPlaceholder: Bool = true
    /// How long to animate the placeholder slide
    open var slideAnimationDuration: TimeInterval = 0.15
    /// An X-offset for the placeholder text from its bounds
    open var placeholderOffsetXDefault: CGFloat = 0.0
    /// An X-offset for the placeholder while slid upward
    open var placeholderOffsetXSlid: CGFloat = 0.0
    /// An Y-offset for the placeholder text from its bounds
    open var placeholderOffsetYDefault: CGFloat = 0.0
    /// An Y-offset for the placeholder while slid upward
    open var placeholderOffsetYSlid: CGFloat = 0.0

    /// Leading constraint of the `UILabel` of the sliding placeholder
    var slidingPlaceholderLeadingConstraint: NSLayoutConstraint?
    /// Center-Y constraint of the `UILabel` of the sliding placeholder
    var slidingPlaceholderCenterYConstraint: NSLayoutConstraint?

    /// Gets the placeholder's rectangle (wrapper for `placeholderRectForBounds:`)
    open var placeholderRect: CGRect {
        return self.placeholderRect(forBounds: bounds)
    }

    /// The placeholder label
    open var placeholderLabel: UILabel?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        selfInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selfInit()
    }


    /**
        Single point of initialization for `self`.
    */
    open func selfInit() {
        addTarget(self,
                  action: #selector(SATextField.textFieldDidBeginEditing(_:)),
                  for: UIControlEvents.editingDidBegin
        )
        addTarget(self,
                  action: #selector(SATextField.textFieldDidEndEditing(_:)),
                  for: UIControlEvents.editingDidEnd
        )
        addTarget(self,
                  action: #selector(SATextField.textFieldDidChange(_:)),
                  for: UIControlEvents.editingChanged
        )
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        configurePlaceholder()
        configurePlaceholderText()
        setSlidingPlaceholder(false)
    }

    /**
        Moves and sets the sldiing holder into the position it should be given the text field's
        state.

        - parameter animated: Whether to animate the transition. default=true
    */
    func setSlidingPlaceholder(_ animated: Bool = true) {
        if isFirstResponder || !(text?.isEmpty ?? true) {
            placeholderLabel?.setAnchorPoint(CGPoint(x: 0.625, y: 0.5))
            expandPlaceholder(animated: animated)
        } else {
            placeholderLabel?.setAnchorPoint(CGPoint(x: 0.5, y: 0.5))
            collapsePlaceholder(animated: animated)
        }
    }
}

extension SATextField {

    /**
        Subviews belonging to the text view.
     */
    public enum ViewIdentifiers: Int {
        case slidePlaceholderLabel = 1
    }

    // MARK: - Text field delegation
    @objc open func textFieldDidChange(_ textField: UITextField) {
        if textField === self {
            setSlidingPlaceholder()
        }
    }

    @objc open func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField === self {
            setSlidingPlaceholder()
        }
    }

    @objc open func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === self {
            setSlidingPlaceholder()
        }
    }
}

fileprivate extension SATextField {

    /**
        Configures the placeholder relative to the status of the
        `placeholderText` variable.
    */
    func configurePlaceholder() {
        if let placeholderText = placeholderText, !placeholderText.isEmpty {
            let label = placeholderLabel ?? UILabel(frame: placeholderRect)
            label.tag = ViewIdentifiers.slidePlaceholderLabel.rawValue
            label.translatesAutoresizingMaskIntoConstraints = false
            if label.superview == nil {
                addSubview(label)
                addConstraints(configurePlaceholderConstraints(label))
            }

            placeholderOffsetYSlid = placeholderOffsetYDefault - label.frame.height
            label.isHidden = false
            placeholderLabel = label
        } else {
            placeholderLabel?.removeFromSuperview()
        }
    }

    func configurePlaceholderText() {
        placeholderLabel?.text = placeholderText
        placeholderLabel?.font = font
        placeholderLabel?.textColor = placeholderTextColor
    }

    func configurePlaceholderConstraints(_ label: UILabel) -> [NSLayoutConstraint] {
        slidingPlaceholderLeadingConstraint = NSLayoutConstraint(
            item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading,
            multiplier: 1.0, constant: placeholderOffsetXDefault)
        slidingPlaceholderCenterYConstraint = NSLayoutConstraint(
            item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY,
            multiplier: 1.0, constant: placeholderOffsetYDefault)
        let width = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal,
                                       toItem: self, attribute: .width, multiplier: 1.0,
                                       constant: 0.0),
            height = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal,
                                        toItem: self, attribute: .height, multiplier: 1.0,
                                        constant: 0.0)

        return [slidingPlaceholderLeadingConstraint!, slidingPlaceholderCenterYConstraint!, width,
            height
        ]
    }

    func collapsePlaceholder(animated: Bool = true) {
        let changes = { () -> () in
            self.slidingPlaceholderLeadingConstraint?.constant = self.placeholderOffsetXDefault
            self.slidingPlaceholderCenterYConstraint?.constant = self.placeholderOffsetYDefault
            self.placeholderLabel?.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            self.placeholderLabel?.textColor = self.placeholderTextColor
            self.placeholderLabel?.alpha = 1.0
            self.layoutIfNeeded()
        }

        animated ?
            UIView.animate(withDuration: slideAnimationDuration, animations: changes) :
            changes()
    }

    func expandPlaceholder(animated: Bool = true) {
        let changes = { () -> () in
            self.slidingPlaceholderLeadingConstraint?.constant = self.placeholderOffsetXSlid
            self.slidingPlaceholderCenterYConstraint?.constant = self.placeholderOffsetYSlid
            self.placeholderLabel?.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
            self.placeholderLabel?.textColor = self.isFirstResponder ?
                self.placeholderTextColorFocused :
                self.placeholderTextColor
            self.layoutIfNeeded()
        }

        animated ?
            UIView.animate(withDuration: slideAnimationDuration, animations: changes) :
            changes()
    }
}
