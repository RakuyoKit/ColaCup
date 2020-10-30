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
    
    public init(date: Date? = nil) {
        
        self.date = date
        
        let _date = date ?? Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents(Set(arrayLiteral: .year, .month, .day), from: _date)
        
        let startDate = calendar.date(from: components) ?? _date
        
        self.startInterval = startDate.timeIntervalSince1970
        self.endInterval = self.startInterval + (24 * 60 * 60 - 1)
    }
    
    /// The date of the log to be viewed. In days.
    public var date: Date?
    
    /// When previewing logs in a certain period of time, it is used to indicate the **start** time.
    public var startInterval: TimeInterval
    
    /// When previewing logs in a certain period of time, it is used to indicate the **end** time.
    public var endInterval: TimeInterval
}
