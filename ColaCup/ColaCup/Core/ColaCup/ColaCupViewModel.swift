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
}

public extension ColaCupViewModel {
    
    /// Process log data.
    ///
    /// - Parameter completion: The callback when the processing is completed will be executed on the main thread.
    func processLogs(completion: @escaping () -> Void) {
        
        let all = ColaCupSelectedModel(isSelected: true, value: "ALL")
        
        // Because the log volume may be large, a new thread is opened to process the log.
        DispatchQueue.global().async { [weak self] in
            
            guard let this = self else { return }
            
            defer {
                
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
            
            this.integralLogs = { () -> [LogModelProtocol] in
                
                if let date = this.timeModel.targetDate {
                    
                    let _logs: [Log] = this.logManager.readLogFromDisk(logDate: date) ?? []
                    
                    return _logs as [LogModelProtocol]
                }
                
                return this.logManager.logs
                
            }().reversed()
            
            guard !this.integralLogs.isEmpty else {
                this.filterModel.flags = [all]
                this.filterModel.modules = [all]
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
            
            var _flags = Array(flagSet).sorted().map { ColaCupSelectedModel(value: $0) }
            _flags.insert(all, at: 0)
            this.filterModel.flags = _flags
            
            var _modules = Array(moduleSet).sorted().map { ColaCupSelectedModel(value: $0) }
            _modules.insert(all, at: 0)
            this.filterModel.modules = _modules
        }
    }
    
    /// Processing module data changes.
    ///
    /// - Parameter completion: The callback when the processing is completed will be executed on the main thread.
    func processModuleChange(completion: @escaping () -> Void) {
        
        // No callback required
        guard !integralLogs.isEmpty else { return }
        
        // Because the log volume may be large, a new thread is opened to process the log.
        DispatchQueue.global().async { [weak self] in
            
            guard let this = self else { return }
            
            defer {
                
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
            
            let selectModules = this.filterModel.modules.filter { $0.isSelected }.map { $0.value }
            
            var flagSet = Set<Log.Flag>()
            
            if selectModules == ["ALL"] {
                
                this.showLogs = this.integralLogs
                this.showLogs.forEach { flagSet.insert($0.flag) }
                
            } else {
                
                this.showLogs = this.integralLogs.filter {
                    
                    let value = selectModules.contains($0.module)
                    if value { flagSet.insert($0.flag) }
                    
                    return value
                }
            }
            
            // Record
            var _flags = Array(flagSet).sorted().map { ColaCupSelectedModel(value: $0) }
            _flags.insert(ColaCupSelectedModel(isSelected: true, value: "ALL"), at: 0)
            this.filterModel.flags = _flags
        }
    }
}

// MARK: - Search

public extension ColaCupViewModel {
    
    /// Search the log.
    ///
    /// - Parameters:
    ///   - keyword: Search keywords.
    ///   - executeImmediately: Whether to perform the search immediately. If it is `false`, the throttling algorithm will be used. See the `throttler` property for details.
    ///   - completion: The callback when the search is completed will be executed on the main thread.
    func search(with keyword: String?, executeImmediately: Bool, completion: @escaping () -> Void) {
        
        // Really responsible for the search method.
        let searchBlock: () -> Void = { [weak self] in
            guard let this = self else { return }
            
            defer {
                
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
            
            this.filterModel.searchKeyword = keyword
            
            var conditions: [(LogModelProtocol) -> Bool] = []
            
            let selectedFlags = this.filterModel.flags.filter { $0.isSelected }.map { $0.value }
            
            if !selectedFlags.isEmpty && selectedFlags != ["ALL"] {
                conditions.append({ selectedFlags.contains($0.flag) })
            }
            
            if let _keyword = keyword, !_keyword.isEmpty {
                conditions.append({ $0.safeLog.contains(_keyword) })
            }
            
            this.showLogs = this.integralLogs.filter(with: conditions)
        }
        
        if executeImmediately {
            searchBlock()
        } else {
            
            // In a certain time frame, the search method can only be executed once
            throttler.execute(searchBlock)
        }
    }
}

// MARK: - Flag

extension ColaCupViewModel {
    
    public func updateFlags(_ flags: [ColaCupSelectedModel<Log.Flag>]) {
        filterModel.flags = flags
    }
    
    /// Execute when the flag button is clicked.
    ///
    /// - Parameters:
    ///   - index: Index of the choosed flag.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    public func clickFlag(at index: Int, completion: @escaping () -> Void) {
        
        var conditions: [(LogModelProtocol) -> Bool] = []
        
        if let keyword = filterModel.searchKeyword, !keyword.isEmpty {
            conditions.append({ $0.safeLog.contains(keyword) })
        }
        
        if !filterModel.flags[0].isSelected {
            
            let selectFlags = filterModel.flags.filter { $0.isSelected }.map { $0.value }
            
            conditions.append({ selectFlags.contains($0.flag) })
        }
        
        showLogs = integralLogs.filter(with: conditions)
        
        // Return to the main thread callback controller
        DispatchQueue.main.async(execute: completion)
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
