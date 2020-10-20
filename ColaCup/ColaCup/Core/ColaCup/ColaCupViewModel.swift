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
    
    /// A model for storing time-related data.
    public lazy var timeModel = TimePopoverModel()
    
    /// A model for storing data related to filter options.
    public lazy var filterModel = FilterPopoverModel()
    
    /// The log data to be displayed.
    public lazy var showLogs: [LogModelProtocol] = []
    
    /// Contains the complete log data under the current date.
    private lazy var integralLogs: [LogModelProtocol] = []
    
    /// Used to restrict the execution of search functions.
    private lazy var throttler = Throttler(seconds: 0.3)
    
    /// Whether the user modified the date of the log to be viewed.
    private lazy var isDateChanged: Bool = false
}

// MARK: - Initial data

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
            
            this.integralLogs = { () -> [LogModelProtocol] in
                
                if let date = this.timeModel.date {
                    
                    let _logs: [Log] = this.logManager.readLogFromDisk(logDate: date) ?? []
                    
                    return _logs as [LogModelProtocol]
                }
                
                return this.logManager.logs
                
            }().reversed()
            
            guard !this.integralLogs.isEmpty else {
                this.filterModel.flags = [.all]
                this.filterModel.modules = [.all]
                this.showLogs = []
                this.integralLogs = []
                return
            }
            
            var flagSet = Set<Log.Flag>()
            var moduleSet = Set<String>()
            
            for log in this.integralLogs {
                
                flagSet.insert(log.flag)
                moduleSet.insert(log.module)
            }
            
            // Record
            this.showLogs = this.integralLogs
            
            var _flags = Array(flagSet).sorted().map { SelectedModel(value: $0) }
            _flags.insert(.all, at: 0)
            this.filterModel.flags = _flags
            
            var _modules = Array(moduleSet).sorted().map { SelectedModel(value: $0) }
            _modules.insert(.all, at: 0)
            this.filterModel.modules = _modules
        }
    }
}

// MARK: - Update Data

public extension ColaCupViewModel {
    
    func updateSearchKeyword(_ keyword: String) {
        filterModel.searchKeyword = keyword
    }
    
    func updateFlags(_ flags: [SelectedModel<Log.Flag>]) {
        filterModel.flags = flags
    }
    
    func updateModules(_ modules: [SelectedModel<String>]) {
        filterModel.modules = modules
    }
    
    func updateTimeModel(_ model: TimePopoverModel) {
        
        isDateChanged = model.date != timeModel.date
        
        timeModel = model
        
        guard isDateChanged, let targetDate = timeModel.date else { return }
        
        let calendar = Calendar.current
        
        var targetComponents = calendar.dateComponents(
            Set(arrayLiteral: .year, .month, .day),
            from: targetDate
        )
        
        let startComponents = calendar.dateComponents(
            Set(arrayLiteral: .hour, .minute),
            from: timeModel.period.start
        )
        
        targetComponents.setValue(startComponents.value(for: .hour), for: .hour)
        targetComponents.setValue(startComponents.value(for: .minute), for: .minute)
        
        if let startDate = calendar.date(from: targetComponents) {
            timeModel.period.start = startDate
        }
        
        let endComponents = calendar.dateComponents(
            Set(arrayLiteral: .hour, .minute),
            from: timeModel.period.end
        )
        
        targetComponents.setValue(endComponents.value(for: .hour), for: .hour)
        targetComponents.setValue(endComponents.value(for: .minute), for: .minute)
        
        if let endDate = calendar.date(from: targetComponents) {
            timeModel.period.end = endDate
        }
    }
}

public extension ColaCupViewModel {
    
    /// Refresh log data.
    ///
    /// - Parameters:
    ///   - executeImmediately: Whether to perform the search immediately. If it is `false`, the throttling algorithm will be used. See the `throttler` property for details.
    ///   - completion: Completed callback. Will be guaranteed to execute on the main thread.
    func refreshLogData(executeImmediately: Bool, completion: @escaping () -> Void) {
        
        // Really responsible for the filter method.
        let filterBlock: () -> Void = { [weak self] in
            
            guard let this = self else { return }
            
            defer {
                
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
            
            // If the user modifies the date, the log data will be retrieved.
            if this.isDateChanged, let date = this.timeModel.date {
                
                this.isDateChanged = false
                
                let _logs: [Log] = this.logManager.readLogFromDisk(logDate: date) ?? []
                this.integralLogs = _logs as [LogModelProtocol]
            }
            
            var conditions: [(LogModelProtocol) -> Bool] = []
            
            // Period
            let period = this.timeModel.period
            let startTimestamp = period.start.timeIntervalSince1970
            let endTimestamp = period.end.timeIntervalSince1970
            
            conditions.append({ $0.timestamp >= startTimestamp && $0.timestamp <= endTimestamp })
            
            // Search
            if let keyword = this.filterModel.searchKeyword, !keyword.isEmpty {
                conditions.append({ $0.safeLog.contains(keyword) })
            }
            
            // Flag
            if !this.filterModel.flags[0].isSelected {
                
                let selectFlags = this.filterModel.flags.filter { $0.isSelected }.map { $0.value }
                conditions.append({ selectFlags.contains($0.flag) })
            }
            
            // Module
            if !this.filterModel.modules[0].isSelected {
                
                let selectModules = this.filterModel.modules.filter { $0.isSelected }.map { $0.value }
                conditions.append({ selectModules.contains($0.module) })
            }
            
            this.showLogs = this.integralLogs.filter(with: conditions)
        }
        
        if executeImmediately {
            filterBlock()
        } else {
            
            // In a certain time frame, the search method can only be executed once
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
