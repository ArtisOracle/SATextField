//
//  Extensions.swift
//  SATextField
//
//  Created by Stefan Arambasich on 10/14/2015.
//  Copyright © 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

extension UIView {
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
    func pinToParentView(_ leading: CGFloat = 0.0, top: CGFloat = 0.0, trailing: CGFloat = 0.0, bottom: CGFloat = 0.0) {
        var constraints = [NSLayoutConstraint]()

        constraints.append(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: self.superview, attribute: .top, multiplier: 1.0, constant: top))
        constraints.append(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: self.superview, attribute: .leading, multiplier: 1.0, constant: leading))
        constraints.append(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.superview, attribute: .bottom, multiplier: 1.0, constant: bottom))
        constraints.append(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: self.superview, attribute: .trailing, multiplier: 1.0, constant: trailing))

        self.superview?.addConstraints(constraints)
        self.superview?.setNeedsDisplay()
    }

    /**
        Sets the anchor point. Used for performing animations around points other than the center.

        anchorPoint The desired anchor point of the view.
    */
    func setAnchorPoint(_ anchorPoint: CGPoint) {
        var newPoint = CGPoint(x: self.bounds.size.width * anchorPoint.x, y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(x: self.bounds.size.width * self.layer.anchorPoint.x, y: self.bounds.size.height * self.layer.anchorPoint.y)

        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)

        var position = self.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }
}
