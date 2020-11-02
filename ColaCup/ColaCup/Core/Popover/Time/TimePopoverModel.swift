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
        self.zeroHour = TimePopoverModel.getZeroHour(of: self.date)
        self.startInterval = self.zeroHour
        self.endInterval = self.startInterval + (24 * 60 * 60 - 1)
    }
    
    /// The date of the log to be viewed. In days.
    public var date: Date? {
        didSet {
            zeroHour = TimePopoverModel.getZeroHour(of: date)
        }
    }
    
    /// The timestamp of the zero point of the date corresponding to date.
    public private(set) var zeroHour: TimeInterval
    
    /// When previewing logs in a certain period of time, it is used to indicate the **start** time.
    public var startInterval: TimeInterval
    
    /// When previewing logs in a certain period of time, it is used to indicate the **end** time.
    public var endInterval: TimeInterval
}

private extension TimePopoverModel {
    
    static func getZeroHour(of date: Date?) -> TimeInterval {
        
        let _date = date ?? Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents(Set(arrayLiteral: .year, .month, .day), from: _date)
        
        let startDate = calendar.date(from: components) ?? _date
        
        return startDate.timeIntervalSince1970
    }
}
