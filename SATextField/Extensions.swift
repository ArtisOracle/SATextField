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

        - parameter leading: Leading space default=0.0
        - parameter top: Top space default=0.0
        - parameter trailing: Trailing space default=0.0
        - parameter bottom: Bottom space default=0.0
    */
    func pinToParentView(_ leading: CGFloat = 0.0,
                         top: CGFloat = 0.0,
                         trailing: CGFloat = 0.0,
                         bottom: CGFloat = 0.0) {

        self.superview?.addConstraints([
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: superview,
                               attribute: .top, multiplier: 1.0, constant: top),
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal,
                               toItem: superview, attribute: .leading, multiplier: 1.0,
                               constant: leading),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: superview,
                               attribute: .bottom, multiplier: 1.0, constant: bottom),
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal,
                               toItem: superview, attribute: .trailing, multiplier: 1.0,
                               constant: trailing),
            ])
        self.superview?.setNeedsDisplay()
    }

    /**
        Sets the anchor point. Used for performing animations around points other than the center.

     anchorPoint The desired anchor point of the view.
     */
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
