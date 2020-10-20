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
        
        self.period = DateInterval(start: startDate, duration: 24 * 60 * 60 - 1)
    }
    
    /// The date of the log to be viewed. In days.
    public var date: Date?
    
    /// The log to be viewed and the time period. In minutes.
    public var period: DateInterval
}
