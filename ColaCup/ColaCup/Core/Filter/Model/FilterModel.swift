//
//  FilterModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

/// The model used to record the currently selected filter criteria.
public struct FilterModel {
    /// Sort order of logs.
    public var sort: Sort = .default
    
    /// The currently selected time range.
    public var timeRange: FilterTimeRange = .default
    
    /// A collection of all log flags.
    /// The outer isSelected property allows you to determine if the state is selected.
    public var flags: Set<Flag> = [FilterModel.allFlag]
    
    /// The set of all modules.
    /// The outer isSelected property allows you to determine if the state is selected.
    public var modules: Set<String> = [FilterModel.allFlag]
}

public extension FilterModel {
    /// Used to represent all
    static let allFlag = "ALL".locale
}

// MARK: - Equatable

extension FilterModel: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.sort == rhs.sort) &&
            lhs.timeRange.isExactlyEqual(to: rhs.timeRange) &&
            (lhs.flags == rhs.flags) &&
            (lhs.modules == rhs.flags)
    }
}
