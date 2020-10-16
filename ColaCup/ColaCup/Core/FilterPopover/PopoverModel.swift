//
//  PopoverModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/16.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

/// Data source model for `FilterPopover`.
public struct PopoverModel {
    
    public init(
        appearY: CGFloat = 0,
        searchKeyword: String? = nil,
        selectedFlags: [ColaCupSelectedModel<Log.Flag>] = [],
        targetDate: Date? = nil,
        targetPeriod: (start: TimeInterval, end: TimeInterval) = (start: TimeInterval(0), end: Date().timeIntervalSince1970),
        selectedModules: [ColaCupSelectedModel<String>] = []
    ) {
        self.appearY = appearY
        self.searchKeyword = searchKeyword
        self.flags = selectedFlags
        self.targetDate = targetDate
        self.targetPeriod = targetPeriod
        self.modules = selectedModules
    }
    
    /// Y coordinate of the point.
    public var appearY: CGFloat
    
    /// Keywords used when searching.
    public var searchKeyword: String?
    
    /// Currently selected flags.
    public var flags: [ColaCupSelectedModel<Log.Flag>]
    
    /// The date of the log to be viewed. In days.
    public var targetDate: Date?
    
    /// The log to be viewed and the time period. In minutes.
    public var targetPeriod: (start: TimeInterval, end: TimeInterval)
    
    /// Currently selected modules.
    public var modules: [ColaCupSelectedModel<String>]
}
