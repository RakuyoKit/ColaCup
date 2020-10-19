//
//  TimePopoverModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Data source model for `TimePopover`.
public struct TimePopoverModel {
    
    public init(
        targetDate: Date? = nil,
        targetPeriod: (start: TimeInterval, end: TimeInterval) = (start: TimeInterval(0), end: Date().timeIntervalSince1970)
    ) {
        self.targetDate = targetDate
        self.targetPeriod = targetPeriod
    }
    
    /// The date of the log to be viewed. In days.
    public var targetDate: Date?
    
    /// The log to be viewed and the time period. In minutes.
    public var targetPeriod: (start: TimeInterval, end: TimeInterval)
}
