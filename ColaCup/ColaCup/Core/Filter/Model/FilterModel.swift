//
//  FilterModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

import RaLog

/// The model used to record the currently selected filter criteria.
public struct FilterModel {
    /// Sort order of logs.
    public var sort: Sort = .negative
    
    /// The currently selected time range.
    public var selectedTimeRange: FilterTimeRange = .currentPage
    
    /// The set of currently selected flags.
    public var selectedFlags = Set<Log.Flag>()
    
    /// The set of currently selected modules.
    public var selectedModules = Set<String>()
}
