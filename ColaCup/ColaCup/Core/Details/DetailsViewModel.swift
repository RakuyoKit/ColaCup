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
    
    /// The detailed log data to be viewed.
    private let log: Log
    
    /// List data source.
    open lazy var dataSource: [DetailsSectionModel] = createDataSource()
}

extension DetailsViewModel {
    
    /// Controller title
    open var title: String { log.flag }
}

extension DetailsViewModel {
    
    /// Create list data source
    func createDataSource() -> [DetailsSectionModel] {
        
        let content = log.safeLog.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var dataSource = [
            DetailsSectionModel(title: "Content", value: content),
            DetailsSectionModel(title: "Time", value: log.formatTime),
            DetailsSectionModel(title: "Position", items: [
                DetailsCellModel(imageName: "", title: "Module", value: log.module),
                DetailsCellModel(imageName: "", title: "File", value: log.file),
                DetailsCellModel(imageName: "", title: "Line", value: "\(log.line)"),
                DetailsCellModel(imageName: "", title: "Function", value: log.function),
            ]),
        ]
        
        if !content.isEmpty {
            let json = ""
            dataSource.append(DetailsSectionModel(title: "JSON", value: json))
        }
        
        return dataSource
    }
}
