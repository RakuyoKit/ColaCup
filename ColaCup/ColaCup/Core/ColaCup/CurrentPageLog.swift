//
//  CurrentPageLog.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/29.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

struct CurrentPageLog {
    /// The name of the file where the current controller is located.
    let fileName: String
    
    /// The time range from the first log printed on the current page, to the last log.
    let timeRange: Range<TimeInterval>
}
