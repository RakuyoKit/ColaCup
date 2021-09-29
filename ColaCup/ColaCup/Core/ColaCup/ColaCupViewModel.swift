//
//  ColaCupViewModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

public typealias Flag = Log.Flag

/// Mainly used to process log data.
public class ColaCupViewModel {
    /// Use the log manager to initialize the view model.
    ///
    /// - Parameter logManager: The log manager is required to follow the `Storable` protocol.
    public init<T: Storable>(logManager: T.Type) {
        self.logManager = logManager
    }
    
    public typealias CurrentPage = (file: String, isUsedJump: Bool)
    
    /// Used to get the name of the current page from the controller.
    public lazy var getCurrentPage: (() -> CurrentPage?)? = nil
    
    /// The log data to be displayed.
    public private(set) lazy var showLogs: [[LogModelProtocol]] = []
    
    /// currently selected filter condition.
    public private(set) lazy var filterModel = FilterModel() {
        didSet {
            // Determines if the time range is modified.
            // The filter will then be narrowed down based on this property.
            isModifiedTimeRange = !filterModel.timeRange.isExactlyEqual(to: oldValue.timeRange)
        }
    }
    
    /// Initial set of flags.
    public private(set) lazy var allFlags: [Flag] = []
    
    /// Initial set of modules.
    public private(set) lazy var allModules: [String] = []
    
    /// Log manager.
    private let logManager: Storable.Type
    
    /// Contains the complete log data under the current date.
    private lazy var integralLogs: [LogModelProtocol] = [] {
        didSet { statisticalInitialTagAndModule() }
    }
    
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
            self?._processLogs(completion: completion)
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
            self?._filter(completion: completion)
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
    func search(by keyword: String, completion: @escaping ([[LogModelProtocol]]) -> Void) {
        // Really responsible for the filter method.
        let filterBlock: () -> Void = { [weak self] in
            guard let this = self else { return }
            
            var logs = this.integralLogs.filter { $0.safeLog.contains(keyword) }.groupByIdentifier()
            if case .negative = this.filterModel.sort {
                logs = logs.reversed()
            }
            
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
    func _processLogs(completion: @escaping () -> Void) {
        defer {
            // Return to the main thread callback controller
            DispatchQueue.main.async(execute: completion)
        }
        
        // 1. Get all the logs in the initial condition.
        let logs: [LogModelProtocol] = logManager.logs
        
        // 2. Storage Log
        integralLogs = logs
        showLogs = integralLogs.groupByIdentifier().reversed()
    }
    
    func _filter(completion: @escaping () -> Void) {
        defer {
            // Return to the main thread callback controller
            DispatchQueue.main.async(execute: completion)
        }
        
        // 1. Retrieve the complete log data based on the filtering criteria.
        if isModifiedTimeRange {
            integralLogs = {
                switch filterModel.timeRange {
                case .currentPage: return currentPageLogs
                case .launchToDate: return logManager.logs
                case .oneDate(let date): return date?.allLogs(of: logManager) ?? []
                }
            }()
        }
        
        // 2. Filtering according to the criteria selected by the user
        var conditions: [(LogModelProtocol) -> Bool] = []
        
        if let flag = filterModel.flags.first, flag != allFlag {
            let selectFlags = filterModel.flags
            conditions.append({ selectFlags.contains($0.flag) })
        }
        
        if let module = filterModel.modules.first, module != allFlag {
            let selectModules = filterModel.modules
            conditions.append({ selectModules.contains($0.module) })
        }
        
        var logs = integralLogs.filter(with: conditions).groupByIdentifier()
        
        // 3. Sorting the log.
        if case .negative = filterModel.sort {
            logs = logs.reversed()
        }
        
        // 4. Store filter results
        showLogs = logs
    }
    
    /// Display the logs printed in the ColaCup parent page.
    var currentPageLogs: [LogModelProtocol] {
        let allLogs = logManager.logs
        let allCount = allLogs.count
        
        guard allCount != 0 else { return [] }
        
        guard let (_file, isUsedJump) = getCurrentPage?() else {
            Log.error("Failed to get the current controller name! Cannot use \"Show log of current page\" function. All logs since the program was started are displayed.")
            return allLogs
        }
        
        // Filter up to nearly 500 logs.
        let _logs = Array(allLogs[max(allCount - 1000, 0) ..< allCount])
        
        var file = _file
        if _fastPath(file.contains("/")) {
            let components = file.components(separatedBy: "/")
            file = components.last ?? "Failed to get file"
        }
        
        func findRange() -> (start: TimeInterval, end: TimeInterval)? {
            guard let _end = _logs.last(where: { $0.file == file })?.timestamp,
                  let startIndex = _logs.lastIndex(where: { $0.file != file && $0.timestamp < _end }),
                  _logs.indices.contains(startIndex + 1) else {
                return nil
            }
            
            var _start = _logs[startIndex + 1].timestamp
            
            // Compatible with some global logs that are messed up during the page lifecycle.
            if let bufferIndex = _logs[0 ..< startIndex].lastIndex(where: { $0.file == file }) {
                let buffer = _logs[bufferIndex].timestamp
                
                if _start - buffer <= 2 {
                    _start = buffer
                }
            }
            
            return (_start, _end)
        }
        
        var startTime: TimeInterval
        var endTime: TimeInterval
        
        if isUsedJump, let controllerName = file.components(separatedBy: ".").first {
            let appear = "- Appear - \(controllerName)"
            let disappear = "- Disappear - \(controllerName)"
            
            if let _start = _logs.last(where: { $0.logedStr == appear })?.timestamp,
                  let _end = _logs.last(where: { $0.logedStr == disappear })?.timestamp {
                startTime = _start
                endTime = _end
                
            } else {
                guard let range = findRange() else { return [] }
                startTime = range.start
                endTime = range.end
            }
            
        } else {
            guard let range = findRange() else { return [] }
            startTime = range.start
            endTime = range.end
        }
        
        var result: [LogModelProtocol] = []
        
        for log in _logs.reversed() {
            if log.timestamp < startTime { break }
            guard log.timestamp <= endTime && log.timestamp >= startTime && log.file == file else { continue }
            result.append(log)
        }
        
        return result.reversed()
    }
    
    /// Configure the initial set of flags and modules.
    func statisticalInitialTagAndModule() {
        var flagSet = Set<Flag>([allFlag])
        var moduleSet = Set<String>([allFlag])
        
        for log in integralLogs {
            flagSet.insert(log.flag)
            moduleSet.insert(log.module)
        }
        
        allFlags = Array(flagSet).sorted()
        allModules = Array(moduleSet).sorted()
    }
}

// MARK: - Tools

private extension ColaCupViewModel {
    var allFlag: String { FilterModel.allFlag }
}

fileprivate extension Array where Element == LogModelProtocol {
    /// Filter the log array using a series of combined conditions.
    ///
    /// - Parameter conditions: Condition set.
    /// - Returns: Collection of logs that meet the filter criteria.
    func filter(with conditions: [(Element) -> Bool]) -> [Element] {
        guard !conditions.isEmpty else { return self }
        return filter { (log) in conditions.reduce(into: true) { $0 = $0 && $1(log) } }
    }
    
    /// Grouping by `log.identifier` property.
    ///
    /// - Note: When using within this framework, please follow the order of calling `groupByIdentifier` before `reversed`.
    /// - Returns: The collection of logs after grouping.
    func groupByIdentifier() -> [[Element]] {
        var tmp: [String: [Element]] = [:]
        var count = 0
        
        for log in self {
            let identifier = log.identifier ?? "\(count)"
            if let _ = tmp[identifier] {
                tmp[identifier]?.append(log)
            } else {
                tmp[identifier] = [log]
                count += 1
            }
        }
        
        return tmp.values
            .map { $0 }
            .sorted { ($0.first?.timestamp ?? 0) < ($1.first?.timestamp ?? 0) }
    }
}

fileprivate extension Array where Element == [LogModelProtocol] {
    func reversed() -> [Element] {
        var result: [Element] = []
        
        for index in (0 ..< self.count).reversed() {
            let value = self[index]
            if value.count != 1 {
                result.append(value.reversed())
            } else {
                result.append(value)
            }
        }
        
        return result
    }
}

fileprivate extension Date {
    func allLogs(of logManager: Storable.Type) -> [Log]? {
        return logManager.readLogFromDisk(logDate: self)
    }
}
