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
    
    /// The currently selected date. The default is the current day.
    public lazy var selectedDate: Date? = nil
    
    /// Only include the flag used in the currently viewed log. Will not repeat.
    public lazy var flags: [ColaCupSelectedModel] = []
    
    /// Only include the module in the currently viewed log. Will not repeat.
    public lazy var modules: [ColaCupSelectedModel] = []
    
    /// The log data to be displayed.
    public lazy var showLogs: [Log] = []
    
    /// Contains the complete log data under the current date.
    private lazy var integralLogs: [Log] = []
    
    /// Store the currently selected flag. Empty means `ALL` is selected.
    private lazy var selectedFlags: Set<Log.Flag> = Set<Log.Flag>()
    
    /// Used to restrict the execution of search functions.
    private lazy var throttler = Throttler(seconds: 0.3)
    
    /// What the user searched last time.
    private lazy var lastSearchText: String? = nil
}

public extension ColaCupViewModel {
    
    /// Process log data.
    ///
    /// - Parameter completion: The callback when the processing is completed will be executed on the main thread.
    func processLogs(completion: @escaping () -> Void) {
        
        let all = ColaCupSelectedModel(isSelected: true, title: "ALL")
        
        // Because the log volume may be large, a new thread is opened to process the log.
        DispatchQueue.global().async { [weak self] in
            
            guard let this = self else { return }
            
            defer {
                
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
            
            this.integralLogs = { () -> [Log] in
                
                if let date = this.selectedDate {
                    return this.logManager.readLogFromDisk(logDate: date) ?? []
                }
                
                return this.logManager.logs
                
            }().reversed()
            
            guard !this.integralLogs.isEmpty else {
                this.flags = [all]
                this.modules = [all]
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
            
            var _flags = Array(flagSet).sorted().map { ColaCupSelectedModel(title: $0) }
            _flags.insert(all, at: 0)
            this.flags = _flags
            
            var _modules = Array(moduleSet).sorted().map { ColaCupSelectedModel(title: $0) }
            _modules.insert(all, at: 0)
            this.modules = _modules
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
            
            let selectModules = this.modules.filter { $0.isSelected }.map { $0.title }
            
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
            var _flags = Array(flagSet).sorted().map { ColaCupSelectedModel(title: $0) }
            _flags.insert(ColaCupSelectedModel(isSelected: true, title: "ALL"), at: 0)
            this.flags = _flags
        }
    }
}

// MARK: - Flag

extension ColaCupViewModel {
    
    public typealias SelectedFlagCompletion = (_ selectedIndexs: [Int], _ deselectedIndexs: [Int]) -> Void
    
    /// Execute when the flag button is clicked.
    ///
    /// - Parameters:
    ///   - index: Index of the choosed flag.
    ///   - isSelectButton: Whether the button is selected.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    public func clickFlag(at index: Int, isSelectButton: Bool, completion: @escaping SelectedFlagCompletion) {
        
        if flags[index].isSelected {
            
            flags[index].isSelected = isSelectButton
            deselectedFlag(at: index, completion: completion)
            
        } else {
            flags[index].isSelected = isSelectButton
            selectedFlag(at: index, completion: completion)
        }
    }
    
    /// Called when the flag is selected.
    ///
    /// - Parameters:
    ///   - index: Index of the choosed flag.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    private func selectedFlag(at index: Int, completion: @escaping SelectedFlagCompletion) {
        
        flags[index].isSelected = true
        
        var deselectedIndexs: [Int] = []
        
        var conditions: [(Log) -> Bool] = []
        
        if let keyword = lastSearchText, !keyword.isEmpty {
            conditions.append({ $0.safeLog.contains(keyword) })
        }
        
        switch flags[index].title {
        
        case "ALL":
            
            let count = flags.count
            
            for i in 1 ..< count {
                
                guard flags[i].isSelected else { continue }
                
                flags[i].isSelected = false
                selectedFlags.remove(flags[i].title)
                
                deselectedIndexs.append(i)
            }
            
        default:
            
            selectedFlags.insert(flags[index].title)
            
            if flags[0].isSelected {
                flags[0].isSelected = false
                deselectedIndexs.append(0)
            }
            
            let selectFlags = flags.filter { $0.isSelected }.map { $0.title }
            
            conditions.append({ selectFlags.contains($0.flag) })
        }
        
        showLogs = integralLogs.filter(with: conditions)
        
        // Return to the main thread callback controller
        DispatchQueue.main.async {
            completion([], deselectedIndexs)
        }
    }
    
    /// Called when the flag is deselected.
    ///
    /// - Parameters:
    ///   - index: The index of the deselected flag.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    private func deselectedFlag(at index: Int, completion: @escaping SelectedFlagCompletion) {
        
        guard flags[index].title != "ALL" else { return }
        
        flags[index].isSelected = false
        selectedFlags.remove(flags[index].title)
        
        var selectedIndexs: [Int] = []
        
        let selectFlags = flags.filter { $0.isSelected }.map { $0.title }
        
        var conditions: [(Log) -> Bool] = []
        
        if let keyword = lastSearchText, !keyword.isEmpty {
            conditions.append({ $0.safeLog.contains(keyword) })
        }
        
        if selectFlags.isEmpty {
            flags[0].isSelected = true
            selectedIndexs.append(0)
            
        } else {
            conditions.append({ selectFlags.contains($0.flag) })
        }
        
        showLogs = integralLogs.filter(with: conditions)
        
        // Return to the main thread callback controller
        DispatchQueue.main.async {
            completion(selectedIndexs, [index])
        }
    }
}

// MARK: - Search

extension ColaCupViewModel {
    
    func search(with keyword: String?, executeImmediately: Bool, completion: @escaping () -> Void) {
        
        guard keyword != lastSearchText else { return }
        
        // Really responsible for the search method.
        let searchBlock: () -> Void = { [weak self] in
            guard let this = self else { return }
            
            defer {
                
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
            
            this.lastSearchText = keyword
            
            var conditions: [(Log) -> Bool] = []
            
            if !this.selectedFlags.isEmpty {
                conditions.append({ this.selectedFlags.contains($0.flag) })
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

// MARK: - Filter log

fileprivate extension Array where Element == Log {
    
    func filter(with conditions: [(Log) -> Bool]) -> [Log] {
        guard !conditions.isEmpty else { return self }
        return filter { (log) in conditions.reduce(into: true) { $0 = $0 && $1(log) } }
    }
}
