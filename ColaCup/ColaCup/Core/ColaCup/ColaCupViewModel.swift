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
    
    /// The log data to be displayed.
    public lazy var showLogs: [LogModelProtocol] = []
    
    /// currently selected filter condition.
    public private(set) lazy var filterModel = FilterModel() {
        didSet {
            // Determines if the time range is modified.
            // The filter will then be narrowed down based on this property.
            isModifiedTimeRange = filterModel.timeRange != oldValue.timeRange
        }
    }
    
    /// Log manager.
    private let logManager: Storable.Type
    
    /// Contains the complete log data under the current date.
    private lazy var integralLogs: [LogModelProtocol] = []
    
    /// Initial set of flags.
    private lazy var allFlags: [Log.Flag] = []
    
    /// Initial set of modules.
    private lazy var allModules: [String] = []
    
    /// Used to restrict the execution of search functions.
    private lazy var throttler = Throttler(seconds: 0.3)
    
    /// Whether the time range is modified in the filter page
    private lazy var isModifiedTimeRange: Bool = false
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
            
            // 1. Get all the logs in the initial condition.
            let logs: [LogModelProtocol] = this.currentPageLogs
            
            // 2. Storage Log
            this.integralLogs = logs.reversed()
            this.showLogs = this.integralLogs
            
            // 3. Configure the initial set of flags and modules.
            var flagSet = Set<Log.Flag>([this.allFlag])
            var moduleSet = Set<String>([this.allFlag])
            
            for log in this.integralLogs {
                flagSet.insert(log.flag)
                moduleSet.insert(log.module)
            }
            
            this.allFlags = Array(flagSet).sorted()
            this.allModules = Array(moduleSet).sorted()
        }
    }
    
    /// Performs a filtering operation.
    ///
    /// - Parameters:
    ///   - filterModel: User-selected filters.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    func filter(by filter: FilterModel, completion: @escaping () -> Void) {
        filterModel = filter
        
        // Because the log volume may be large, a new thread is opened to process the log.
        DispatchQueue.global().async { [weak self] in
            guard let this = self else { return }
            
            defer {
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
            
            // 1. Retrieve the complete log data based on the filtering criteria.
            if this.isModifiedTimeRange {
                this.integralLogs = {
                    switch this.filterModel.timeRange {
                    case .currentPage: return this.currentPageLogs
                    case .launchToDate: return this.logManager.logs
                        
                    case .period(let date, let start, let end):
                        let _logs: [Log] = this.logManager.readLogFromDisk(logDate: date) ?? []
                        return _logs.filter { $0.timestamp >= start && $0.timestamp <= end }
                    }
                }()
            }
            
            // 2. Filtering according to the criteria selected by the user
            var conditions: [(LogModelProtocol) -> Bool] = []
            
            if let flag = this.filterModel.flags.first, flag != this.allFlag {
                let selectFlags = this.filterModel.flags
                conditions.append({ selectFlags.contains($0.flag) })
            }
            
            if let module = this.filterModel.modules.first, module != this.allFlag {
                let selectModules = this.filterModel.modules
                conditions.append({ selectModules.contains($0.module) })
            }
            
            var logs = this.integralLogs.filter(with: conditions)
            
            // 3. Sorting the log.
            if case .negative = this.filterModel.sort {
                logs = logs.reversed()
            }
            
            // 4. Store filter results
            this.showLogs = logs
        }
    }
    
    /// Is a filter item currently selected.
    ///
    /// - Parameter newFilter: Data to be judged.
    /// - Returns: Does it contain a filter item.
    func isHasFilterItem(with newFilter: FilterModel) -> Bool {
        return newFilter != FilterModel()
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

private extension ColaCupViewModel {
    /// Display the logs printed in the ColaCup parent page.
    var currentPageLogs: [LogModelProtocol] {
        #warning("TODO The logic here is not available yet")
        return logManager.logs
    }
    
    var allFlag: String { FilterModel.allFlag }
}

// MARK: - Filter log

fileprivate extension Array where Element == LogModelProtocol {
    func filter(with conditions: [(Element) -> Bool]) -> [Element] {
        guard !conditions.isEmpty else { return self }
        return filter { (log) in conditions.reduce(into: true) { $0 = $0 && $1(log) } }
    }
}
