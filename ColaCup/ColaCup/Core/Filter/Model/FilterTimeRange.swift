//
//  FilterRange.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

/// The logs can be filtered by time dimension in the following ways.
public enum FilterTimeRange {
    /// Display the logs printed in the ColaCup parent page.
    case currentPage
    
    /// All logs from the start of the app until it enters ColaCup.
    case launchToDate
    
    /// Log of a certain day.
    case oneDate(date: Date?)
}

public extension FilterTimeRange {
    static let `default`: FilterTimeRange = .launchToDate
}

// MARK: - Equatable

extension FilterTimeRange: Equatable {
    private var identifier: Int {
        switch self {
        case .currentPage: return 0
        case .launchToDate: return 1
        case .oneDate: return 2
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    func isExactlyEqual(to rhs: Self) -> Bool {
        if case .oneDate(let lhsDate) = self, case .oneDate(let rhsDate) = rhs {
            return lhsDate == rhsDate
        }
        return self == rhs
    }
}
