//
//  DetailsViewModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/25.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

/// Mainly used to process log data.
public class DetailsViewModel {
    /// Initialize with log data.
    ///
    /// - Parameter log: The detailed log data to be viewed.
    public init(log: LogModelProtocol) {
        self.log = log
    }
    
    /// The detailed log data to be viewed.
    private let log: LogModelProtocol
    
    /// List data source.
    public lazy var dataSource: [DetailsSectionModel] = createDataSource()
    
    /// Log data in JSON format for sharing.
    public lazy var sharedJSON: String = {
        return """
        {
            "time": "\(log.formatTime)",
            "flag": "\(log.flag)",
            "module": "\(log.module)",
            "file": "\(log.file)",
            "function": "\(log.function)",
            "line": \(log.line),
            "content": "\(log.safeLog)"
        }
        """
    }()
}

extension DetailsViewModel {
    /// Controller title
    public var title: String { log.flag }
}

extension DetailsViewModel {
    /// Create list data source
    public func createDataSource() -> [DetailsSectionModel] {
        let content = log.safeLog.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var dataSource = [
            DetailsSectionModel(title: "Time", value: log.formatTime),
            DetailsSectionModel(title: "Content", value: content),
            DetailsSectionModel(title: "Position", items: [
                DetailsCellModel(type: .position, image: "cube.transparent", title: "Module", value: log.module),
                DetailsCellModel(type: .position, image: "doc.text", title: "File", value: log.file),
                DetailsCellModel(type: .position, image: "number", title: "Line", value: "\(log.line)"),
            ]),
            DetailsSectionModel(title: nil, items: [
                DetailsCellModel(type: .function, image: "function", title: "Function", value: log.function),
            ]),
        ]
        
        // Find and intercept json from the log.
        if let json = interceptJSON(from: content) {
            
            // Replace the original json to avoid repeated display.
            dataSource[1].items[0].value = content.replacingOccurrences(
                of: json,
                with: "{ JSON at the bottom }"
            )
            
            dataSource.append(DetailsSectionModel(type: .json, title: "JSON", value: json))
        }
        
        return dataSource
    }
    
    /// Find and intercept json from the given string.
    ///
    /// - Parameter string: Range string.
    /// - Returns: The intercepted json string. Return nil when json is not found.
    private func interceptJSON(from string: String) -> String? {
        let pattern = "(?s)(\\{.*(?=\\})\\}|\\[.*(?=\\])\\])"
        
        // Create a regular expression object.
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }
        
        // Start matching.
        let res = regex.matches(in: string, options: .reportCompletion, range: NSRange(location: 0, length: string.count))
        
        guard !res.isEmpty else { return nil }
        
        let range = res[0].range
        
        let start = string.index(string.startIndex, offsetBy: range.location)
        let end = string.index(start, offsetBy: range.length)
        
        // Intercept json.
        return String(string[start ..< end])
    }
}
