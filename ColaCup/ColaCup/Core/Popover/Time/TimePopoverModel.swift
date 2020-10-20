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
        targetPeriod: (start: TimeInterval, end: TimeInterval)? = nil
    ) {
        
        self.date = targetDate
        
        if let period = targetPeriod {
            self.period = period
            
        } else {
            
            let calendar = Calendar.current
            
            let components = calendar.dateComponents(
                Set(arrayLiteral: .year, .month, .day),
                from: targetDate ?? Date()
            )
            
            let startInterval = calendar.date(from: components)?.timeIntervalSince1970 ?? 0
            
            self.period = (start: startInterval, end: startInterval + 86400 - 1)
        }
    }
    
    /// The date of the log to be viewed. In days.
    public var date: Date?
    
    /// The log to be viewed and the time period. In minutes.
    public var period: (start: TimeInterval, end: TimeInterval)
}
