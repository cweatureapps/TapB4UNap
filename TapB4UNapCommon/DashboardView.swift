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

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var messageLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet var messageLabelLeadingConstraint: NSLayoutConstraint!

    override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        super.awakeAfterUsingCoder(aDecoder)
        return viewFromNib()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.textColor = .whiteColor()
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

    enum DashboardType: String {
        case Begin, Sleeping, Finish
    }

    @IBInspectable
    var message: String = "" {
        didSet {
            messageLabel.text = message
        }
    }

    // MARK: - Different layout for each state of the dashboard

    var dashboardType = DashboardType.Begin

    @IBInspectable
    var type: String = "Begin" {
        didSet {
            dashboardType = DashboardType(rawValue: type)!
            setup()
        }
    }

    private func setup() {
        switch dashboardType {
        case .Begin:
            messageLabel.font = UIFont.systemFontOfSize(24.0, weight: UIFontWeightThin)
            button1.setTitle("Add", forState: .Normal)
            button1.setBackgroundImage(UIImage(named: "icon_add"), forState: .Normal)
            button2.setTitle("Sleep", forState: .Normal)
            button2.setBackgroundImage(UIImage(named: "icon_sleep"), forState: .Normal)
        case .Sleeping:
            messageLabel.font = UIFont.systemFontOfSize(48.0, weight: UIFontWeightThin)
            button1.setTitle("Cancel", forState: .Normal)
            button1.setBackgroundImage(UIImage(named: "icon_cancel"), forState: .Normal)
            button2.setTitle("Wake", forState: .Normal)
            button2.setBackgroundImage(UIImage(named: "icon_wake"), forState: .Normal)
        case .Finish:
            messageLabel.font = UIFont.systemFontOfSize(24.0, weight: UIFontWeightThin)
            button1.setTitle("Edit", forState: .Normal)
            button1.setBackgroundImage(UIImage(named: "icon_edit"), forState: .Normal)
            button2.setTitle("Done", forState: .Normal)
            button2.setBackgroundImage(UIImage(named: "icon_tick"), forState: .Normal)
        }
    }

    override func layoutSubviews() {
        if case .Sleeping = dashboardType {
            messageLabelCenterConstraint.active = false
            messageLabelLeadingConstraint.active = true
        } else {
            messageLabelCenterConstraint.active = true
            messageLabelLeadingConstraint.active = false
        }
        super.layoutSubviews()
    }
}
