//
//  CurrentPageLog.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/29.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

public struct CurrentPageLog {
    public init(
        fileName: String,
        timeRange: Range<TimeInterval>
    ) {
        self.fileName = fileName
        self.timeRange = timeRange
    }
    
    /// The name of the file where the current controller is located.
    public let fileName: String
    
    /// The time range from the first log printed on the current page, to the last log.
    public let timeRange: Range<TimeInterval>
}
