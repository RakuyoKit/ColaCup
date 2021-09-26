//
//  FilterRange.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

/// The logs can be filtered by time dimension in the following ways.
public enum FilterTimeRange: CaseIterable {
    /// Display the logs printed in the ColaCup parent page.
    case currentPage
    
    /// All logs from the start of the app until it enters ColaCup.
    case launchToDate
    
    /// Logs for a custom time period.
    case sometime
}
