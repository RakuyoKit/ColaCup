//
//  ColaCupViewModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

/// Mainly used to process log data.
public class ColaCupViewModel {
    /// Use the log manager to initialize the view model.
    ///
    /// - Parameter logManager: The log manager is required to follow the `Storable` protocol.
    public init<T: Storable>(logManager: T.Type) {
        self.logManager = logManager
    }
    
    /// Log manager.
    private let logManager: Storable.Type
    
    /// currently selected filter condition.
    public lazy var filterModel = FilterModel()
    
    /// The log data to be displayed.
    public lazy var showLogs: [LogModelProtocol] = []
    
    /// Contains the complete log data under the current date.
    private lazy var integralLogs: [LogModelProtocol] = []
    
    /// Used to restrict the execution of search functions.
    private lazy var throttler = Throttler(seconds: 0.3)
}

public extension ColaCupViewModel {
    /// Process log data.
    ///
    /// - Parameter completion: The callback when the processing is completed will be executed on the main thread.
    func processLogs(completion: @escaping () -> Void) {
        // Because the log volume may be large, a new thread is opened to process the log.
        DispatchQueue.global().async { [weak self] in
            guard let this = self else { return }
            
            defer {
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
//
//            this.integralLogs = { () -> [LogModelProtocol] in
//                if let date = this.timeModel.date {
//                    let _logs: [Log] = this.logManager.readLogFromDisk(logDate: date) ?? []
//                    return _logs as [LogModelProtocol]
//                }
//                return this.logManager.logs
//            }().reversed()
//
//            guard !this.integralLogs.isEmpty else {
//                this.filterModel.flags = [.all]
//                this.filterModel.modules = [.all]
//                this.showLogs = []
//                this.integralLogs = []
//                return
//            }
//
//            var flagSet = Set<Log.Flag>()
//            var moduleSet = Set<String>()
//
//            for log in this.integralLogs {
//                flagSet.insert(log.flag)
//                moduleSet.insert(log.module)
//            }
//
//            // Record
//            this.showLogs = this.integralLogs
//
//            var _flags = Array(flagSet).sorted().map { SelectedModel(value: $0) }
//            _flags.insert(.all, at: 0)
//            this.filterModel.flags = _flags
//
//            var _modules = Array(moduleSet).sorted().map { SelectedModel(value: $0) }
//            _modules.insert(.all, at: 0)
//            this.filterModel.modules = _modules
        }
    }
    
    /// Search for logs based on keywords.
    ///
    /// Search results are affected by keywords only, not by filtering criteria.
    ///
    /// - Parameters:
    ///   - keyword: User-entered search keywords.
    ///   - completion: Completed callback. Will be guaranteed to execute on the main thread.
    func search(by keyword: String, completion: @escaping ([LogModelProtocol]) -> Void) {
        // Really responsible for the filter method.
        let filterBlock: () -> Void = { [weak self] in
            guard let this = self else { return }
            
            let logs = this.integralLogs.filter { $0.safeLog.contains(keyword) }
            
            // Return to the main thread callback controller
            DispatchQueue.main.async { completion(logs) }
        }
        
        // Automatically determine whether to use the throttling algorithm based on the number of logs.
        // Throttling algorithm: the search method can only be executed once within a certain time frame.
        if integralLogs.count < 3000 {
            filterBlock()
        } else {
            throttler.execute(filterBlock)
        }
    }
}












// MARK: - Sort

public extension ColaCupViewModel {
    /// Reverse log data source
    func reverseDataSource() {
        showLogs.reverse()
    }
}

// MARK: - Filter log

fileprivate extension Array where Element == LogModelProtocol {
    func filter(with conditions: [(Element) -> Bool]) -> [Element] {
        guard !conditions.isEmpty else { return self }
        return filter { (log) in conditions.reduce(into: true) { $0 = $0 && $1(log) } }
    }
}
