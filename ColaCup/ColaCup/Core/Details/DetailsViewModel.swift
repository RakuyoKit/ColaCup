//
//  DetailsViewModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/25.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

/// Mainly used to process log data.
open class DetailsViewModel {
    
    /// Initialize with log data.
    ///
    /// - Parameter log: The detailed log data to be viewed.
    public init(log: Log) {
        self.log = log
    }
    
    private let log: Log
}

extension DetailsViewModel {
    
    /// Controller title
    open var title: String { log.flag }
}
