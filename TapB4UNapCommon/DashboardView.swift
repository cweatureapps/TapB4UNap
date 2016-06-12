//
//  DashboardView.swift
//  TapB4UNap
//
//  Created by Ken Ko on 12/06/2016.
//  Copyright © 2016 Ken Ko. All rights reserved.
//

import UIKit

@IBDesignable
class DashboardView: UIView {

    @IBInspectable var textIsStatic: Bool = false

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!

    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        super.awakeAfterUsingCoder(aDecoder)
        return viewFromNib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.textColor = .whiteColor()
        if !textIsStatic {
            messageLabel.text = ""
        }
        hide()
    }

    func hide() {
        messageLabel.alpha = 0.0
        button1.alpha = 0.0
        button2.alpha = 0.0
    }

    func show() {
        messageLabel.alpha = 1.0
        button1.alpha = 1.0
        button2.alpha = 1.0
    }

    func setupButtons(target target: AnyObject, button1Action: Selector, button2Action: Selector) {
        button1.addTarget(target, action: button1Action, forControlEvents: .TouchUpInside)
        button2.addTarget(target, action: button2Action, forControlEvents: .TouchUpInside)
    }

}

class BeginView: DashboardView {}
class SleepingView: DashboardView {}
class FinishView: DashboardView {}
