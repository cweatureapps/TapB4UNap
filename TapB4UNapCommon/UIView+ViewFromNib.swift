//
//  UIView+ViewFromNib.swift
//  TapB4UNap
//
//  Created by Ken Ko on 12/06/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import UIKit

extension UIView {
    /// The name of the Xib file based on the name of the class. The swift module name is ignored.
    func nibName() -> String {
        return self.dynamicType.description().componentsSeparatedByString(".").last!
    }

    /**
    Loads the first view from a Xib file with the same name as the class, and copying all constraints.
    A class can call this method in awakeAfterUsingCoder: which allows views to be referenced within other views
    in Xibs and Storyboards.
    */
    func viewFromNib() -> UIView {
        var awakeView = self
        if subviews.isEmpty {
            let bundle = NSBundle(forClass: self.dynamicType)
            awakeView = bundle.loadNibNamed(self.nibName(), owner: nil, options: nil).first as! UIView
            awakeView.frame = self.frame
            awakeView.translatesAutoresizingMaskIntoConstraints = self.translatesAutoresizingMaskIntoConstraints

            for constraint in constraints {
                var firstItem = constraint.firstItem
                var secondItem = constraint.secondItem
                if firstItem === self {
                    firstItem = awakeView
                }
                if secondItem === self {
                    secondItem = awakeView
                }
                let awakeViewConstraint = NSLayoutConstraint(item: firstItem,
                    attribute: constraint.firstAttribute,
                    relatedBy: constraint.relation,
                    toItem: secondItem,
                    attribute: constraint.secondAttribute,
                    multiplier: constraint.multiplier,
                    constant: constraint.constant)
                awakeView.addConstraint(awakeViewConstraint)
            }
        }
        return awakeView
    }
}
