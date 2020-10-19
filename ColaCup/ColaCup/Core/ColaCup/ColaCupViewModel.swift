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
    
//    /// The currently selected date. The default is the current day.
//    public lazy var selectedDate: Date? = nil
//
//    /// Only include the flag used in the currently viewed log. Will not repeat.
//    public lazy var flags: [ColaCupSelectedModel<String>] = []
//
//    /// Only include the module in the currently viewed log. Will not repeat.
//    public lazy var modules: [ColaCupSelectedModel<String>] = []
//
//    /// Store the currently selected flag. Empty means `ALL` is selected.
//    private lazy var selectedFlags: Set<Log.Flag> = Set<Log.Flag>()
//
//    /// Used to restrict the execution of search functions.
//    private lazy var throttler = Throttler(seconds: 0.3)
//
//    /// What the user searched last time.
//    private lazy var lastSearchText: String? = nil
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
        
        if filterModel.flags[index].isSelected {
            
            filterModel.flags[index].isSelected = isSelectButton
            deselectedFlag(at: index, completion: completion)
            
        } else {
            filterModel.flags[index].isSelected = isSelectButton
            selectedFlag(at: index, completion: completion)
        }
    }
    
    /// Called when the flag is selected.
    ///
    /// - Parameters:
    ///   - index: Index of the choosed flag.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    private func selectedFlag(at index: Int, completion: @escaping SelectedFlagCompletion) {
        
//        popoverModel.flags[index].isSelected = true
//
//        var deselectedIndexs: [Int] = []
//
//        var conditions: [(LogModelProtocol) -> Bool] = []
//
//        if let keyword = popoverModel.searchKeyword, !keyword.isEmpty {
//            conditions.append({ $0.safeLog.contains(keyword) })
//        }
//
//        switch popoverModel.flags[index].value {
//
//        case "ALL":
//
//            let count = popoverModel.flags.count
//
//            for i in 1 ..< count {
//
//                guard popoverModel.flags[i].isSelected else { continue }
//
//                popoverModel.flags[i].isSelected = false
//                selectedFlags.remove(flags[i].value)
//
//                deselectedIndexs.append(i)
//            }
//
//        default:
//
//            selectedFlags.insert(flags[index].value)
//
//            if flags[0].isSelected {
//                flags[0].isSelected = false
//                deselectedIndexs.append(0)
//            }
//
//            let selectFlags = flags.filter { $0.isSelected }.map { $0.value }
//
//            conditions.append({ selectFlags.contains($0.flag) })
//        }
//
//        showLogs = integralLogs.filter(with: conditions)
//
//        // Return to the main thread callback controller
//        DispatchQueue.main.async {
//            completion([], deselectedIndexs)
//        }
    }
    
    /// Called when the flag is deselected.
    ///
    /// - Parameters:
    ///   - index: The index of the deselected flag.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    private func deselectedFlag(at index: Int, completion: @escaping SelectedFlagCompletion) {
        
//        guard flags[index].value != "ALL" else { return }
//
//        flags[index].isSelected = false
//        selectedFlags.remove(flags[index].value)
//
//        var selectedIndexs: [Int] = []
//
//        let selectFlags = flags.filter { $0.isSelected }.map { $0.value }
//
//        var conditions: [(LogModelProtocol) -> Bool] = []
//
//        if let keyword = lastSearchText, !keyword.isEmpty {
//            conditions.append({ $0.safeLog.contains(keyword) })
//        }
//
//        if selectFlags.isEmpty {
//            flags[0].isSelected = true
//            selectedIndexs.append(0)
//
//        } else {
//            conditions.append({ selectFlags.contains($0.flag) })
//        }
//
//        showLogs = integralLogs.filter(with: conditions)
//
//        // Return to the main thread callback controller
//        DispatchQueue.main.async {
//            completion(selectedIndexs, [index])
//        }
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
        
//        guard keyword != lastSearchText else { return }
//
//        // Really responsible for the search method.
//        let searchBlock: () -> Void = { [weak self] in
//            guard let this = self else { return }
//
//            defer {
//
//                // Return to the main thread callback controller
//                DispatchQueue.main.async(execute: completion)
//            }
//
//            this.lastSearchText = keyword
//
//            var conditions: [(LogModelProtocol) -> Bool] = []
//
//            if !this.selectedFlags.isEmpty {
//                conditions.append({ this.selectedFlags.contains($0.flag) })
//            }
//
//            if let _keyword = keyword, !_keyword.isEmpty {
//                conditions.append({ $0.safeLog.contains(_keyword) })
//            }
//
//            this.showLogs = this.integralLogs.filter(with: conditions)
//        }
//
//        if executeImmediately {
//            searchBlock()
//        } else {
//
//            // In a certain time frame, the search method can only be executed once
//            throttler.execute(searchBlock)
//        }
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
