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
    public var timeRange: FilterTimeRange = .currentPage
    
    /// A collection of all log flags.
    /// The outer isSelected property allows you to determine if the state is selected.
    public var flags: [SelectedModel<Log.Flag>] = []
    
    /// The set of all modules.
    /// The outer isSelected property allows you to determine if the state is selected.
    public var modules: [SelectedModel<String>] = []
}
