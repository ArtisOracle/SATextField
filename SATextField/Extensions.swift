//
//  Extensions.swift
//  SATextField
//
//  Created by Stefan Arambasich on 9/5/2015.
//  Copyright (c) 2015 Stefan Arambasich. All rights reserved.
//

import UIKit

extension UIView {
    /**
        Sets the leading, top, trailing, and bottom constraints with the given amounts
        of this view to its parent view, effectively "pinning" it into its parent.
        Custom offsets are optional; their values default to 0.0.

        Makes calls to `layoutIfNeeded` and `updateConstraints` after adding the constraints.

        :param: leading Leading space (optional).
        :param: top Top space (optional).
        :param: trailing Trailing space (optional).
        :param: bottom Bottom space (optional).
    */
    func pinToParentView(leading: CGFloat = 0.0, top: CGFloat = 0.0, trailing: CGFloat = 0.0, bottom: CGFloat = 0.0) {
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
    func setAnchorPoint(anchorPoint: CGPoint) {
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
