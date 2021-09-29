//
//  FilterSection.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/27.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

/// Filter the individual sections of the page
public enum FilterSection {
    /// Display order
    case sort(title: String, values: [Sort])
    
    /// Time range of logs
    case timeRange(title: String, values: [FilterTimeRange])
    
    /// Flag of the log
    case flag(title: String, values: [Flag])
    
    /// Module of the log
    case module(title: String, values: [String])
}

public extension FilterSection {
    var title: String {
        switch self {
        case .sort(let title, _):
            return title.locale
        case .timeRange(let title, _):
            return title.locale
        case .flag(let title, _):
            return title.locale
        case .module(let title, _):
            return title.locale
        }
    }
}
