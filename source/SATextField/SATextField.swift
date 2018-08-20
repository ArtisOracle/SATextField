//
//  SATextField.swift
//  SATextField
//
//  Created by Stefan Arambasich on 9/3/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

/// Custom `UITextField` featuring a material design-like placeholder label. When unfocused, the
/// placeholder acts the same. When focused, the placeholder label slides above the field so the user
/// can still enter her values without losing a sense of what field she was on.
@IBDesignable open class SATextField: UITextField {

    // MARK: -
    // MARK: Public Properties

    // MARK: UI
    // MARK: `IBInspectable`s

    /// Set the custom placeholder text using this propery.
    @IBInspectable open var placeholderText: String = "" {
        didSet { configurePlaceholder(usingText: placeholderText) }
    }

    /// Use this to change the text color of the placeholder for the default state. Defaults to
    /// gray.
    @IBInspectable open var placeholderTextColor: UIColor = .gray {
        didSet { configurePlaceholder(usingText: placeholderText) }
    }

    /// Use this to change the text color of the placeholder for the slid state. Defaults to white.
    @IBInspectable open var placeholderTextColorFocused: UIColor = .white {
        didSet { configurePlaceholder(usingText: placeholderText) }
    }

    /// Whether to slide the placeholder text from inside the text field
    /// to the top of the text field.
    @IBInspectable open var slidesPlaceholder: Bool = true

    /// How long to animate the placeholder slide.
    open var slideAnimationDuration: TimeInterval = 0.15

    // MARK: -
    // MARK: Private Properties

    /// An X-offset for the placeholder text from its bounds.
    private var placeholderOffsetXDefault: CGFloat = 0.0

    /// An X-offset for the placeholder while slid upward.
    private var placeholderOffsetXSlid: CGFloat = 0.0

    /// An Y-offset for the placeholder text from its bounds.
    private var placeholderOffsetYDefault: CGFloat = 0.0

    /// An Y-offset for the placeholder while slid upward.
    private var placeholderOffsetYSlid: CGFloat = 0.0

    /// Leading constraint of the `UILabel` of the sliding placeholder.
    private var slidingPlaceholderLeadingConstraint: NSLayoutConstraint?

    /// Center-Y constraint of the `UILabel` of the sliding placeholder.
    private var slidingPlaceholderCenterYConstraint: NSLayoutConstraint?

    /// The placeholder label.
    private var placeholderLabel: UILabel?


    // MARK: -
    // MARK: Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
    }

    /// Single point of initialization logic for `self`.
    private func commonInit() {
        addTarget(
            self,
            action: #selector(textFieldDidBeginEditing(_:)),
            for: .editingDidBegin
        )
        addTarget(
            self,
            action: #selector(textFieldDidEndEditing(_:)),
            for: .editingDidEnd
        )
        addTarget(
            self,
            action: #selector(textFieldDidChange(_:)),
            for: .editingChanged
        )
    }

    // MARK: -
    // MARK: Overrides

    open override func layoutSubviews() {
        super.layoutSubviews()

        configurePlaceholder(usingText: placeholderText)
        setSlidingPlaceholder(false)
    }

}

// MARK: -
// MARK: Text field delegation / handlers

extension SATextField {

    @objc open func textFieldDidChange(_ textField: UITextField) {
        setSlidingPlaceholder()
    }

    @objc open func textFieldDidBeginEditing(_ textField: UITextField) {
        setSlidingPlaceholder()
    }

    @objc open func textFieldDidEndEditing(_ textField: UITextField) {
        setSlidingPlaceholder()
    }

}

// MARK: -
// MARK: Placeholder Adjustment

private extension SATextField {

    /// Moves and sets the sldiing holder into the position it should be given the text field's state.
    ///
    /// - Parameter animated: Whether to animate the transition. True by default.
    func setSlidingPlaceholder(_ animated: Bool = true) {
        if isFirstResponder || !(text?.isEmpty ?? true) {
            expandPlaceholder(animated: animated)
        } else {
            collapsePlaceholder(animated: animated)
        }
    }

    /// Configures the placeholder label's text and position. If the text is empty, removes the
    /// label from the view.
    ///
    /// - Parameter text: The text of the placeholder.
    func configurePlaceholder(usingText text: String) {
        if text.isEmpty == false {
            let label = placeholderLabel ?? UILabel(frame: placeholderRect(forBounds: bounds))
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = placeholderText
            label.textColor = placeholderTextColor
            label.textAlignment = .left
            label.font = font
            if label.superview == nil {
                addSubview(label)
                addConstraints(makePlaceholderConstraints(for: label))
            }

            placeholderOffsetYSlid = placeholderOffsetYDefault - label.frame.height - 3.0
            label.isHidden = false

            placeholderLabel = label
        } else {
            placeholderLabel?.removeFromSuperview()
        }
    }

    func makePlaceholderConstraints(for label: UILabel) -> [NSLayoutConstraint] {
        let width, height: NSLayoutConstraint
        if #available(iOS 11, *) {
            slidingPlaceholderLeadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor)
            slidingPlaceholderCenterYConstraint = label.centerYAnchor.constraint(equalTo: centerYAnchor)
            width = label.widthAnchor.constraint(equalTo: widthAnchor)
            height = label.heightAnchor.constraint(equalTo: heightAnchor, constant: 2.0)
        } else {
            slidingPlaceholderLeadingConstraint = NSLayoutConstraint(
                item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading,
                multiplier: 1.0, constant: placeholderOffsetXDefault)
            slidingPlaceholderCenterYConstraint = NSLayoutConstraint(
                item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY,
                multiplier: 1.0, constant: placeholderOffsetYDefault)
            width = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal,
                                       toItem: self, attribute: .width, multiplier: 1.0,
                                       constant: 0.0)
            height = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal,
                                        toItem: self, attribute: .height, multiplier: 1.0,
                                        constant: 2.0)
        }

        return [slidingPlaceholderLeadingConstraint!, slidingPlaceholderCenterYConstraint!, width,
                height
        ]
    }

    func collapsePlaceholder(animated: Bool = true) {
        let changes = {
            guard let placeholderLabel = self.placeholderLabel else { return }

            self.slidingPlaceholderLeadingConstraint?.constant = self.placeholderOffsetXDefault
            self.slidingPlaceholderCenterYConstraint?.constant = self.placeholderOffsetYDefault
            placeholderLabel.setAnchorPoint(CGPoint(x: 0.5, y: 0.5))
            placeholderLabel.transform = CGAffineTransform.identity.scaledBy(x: 1.0, y: 1.0)
            placeholderLabel.textColor = self.isFirstResponder ?
                self.placeholderTextColorFocused :
                self.placeholderTextColor

            self.layoutIfNeeded()
        }

        animated ?
            UIView.animate(withDuration: slideAnimationDuration, animations: changes) :
            changes()
    }

    func expandPlaceholder(animated: Bool = true) {
        let changes = {
            self.slidingPlaceholderLeadingConstraint?.constant = self.placeholderOffsetXSlid
            self.slidingPlaceholderCenterYConstraint?.constant = self.placeholderOffsetYSlid
            self.placeholderLabel?.setAnchorPoint(CGPoint(x: 0.625, y: 0.5))
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


// MARK: -
// MARK: `UIView` Extensions

private extension UIView {

    /// Sets the anchor point. Used for performing animations around points other than the center.
    ///
    /// - Parameter anchorPoint: The desired anchor point of the view.
    func setAnchorPoint(_ anchorPoint: CGPoint) {
        var newPoint = CGPoint(
            x: bounds.size.width * anchorPoint.x,
            y: bounds.size.height * anchorPoint.y),
        oldPoint = CGPoint(
            x: bounds.size.width * layer.anchorPoint.x,
            y: bounds.size.height * layer.anchorPoint.y)

        newPoint = newPoint.applying(transform)
        oldPoint = oldPoint.applying(transform)

        var position = layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        layer.position = position
        layer.anchorPoint = anchorPoint
    }

}
