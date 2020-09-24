//
//  ColaCupViewModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

/// Mainly used to process log data
public class ColaCupViewModel {
    
    /// Use the log manager to initialize the view model.
    ///
    /// - Parameter logManager: The log manager is required to follow the `Storable` protocol.
    public init<T: Storable>(logManager: T.Type) {
        self.logManager = logManager
    }
    
    /// The currently selected date. The default is the current day.
    public lazy var selectedDate: Date? = nil
    
    /// Only include the flag used in the currently viewed log. Will not repeat.
    public lazy var flags: [ColaCupSelectedModel] = []
    
    /// Only include the module in the currently viewed log. Will not repeat.
    public lazy var modules: [ColaCupSelectedModel] = []
    
    /// The log data to be displayed.
    public lazy var logs: [Log] = []
    
    /// Log manager.
    private let logManager: Storable.Type
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
            
            this.logs = {
                
                if let date = this.selectedDate {
                    return this.logManager.readLogFromDisk(logDate: date) ?? []
                }
                
                return this.logManager.logs
            }()
            
            guard !this.logs.isEmpty else {
                this.flags = [all]
                this.modules = [all]
                return
            }
            
            var flagSet = Set<Log.Flag>()
            var moduleSet = Set<String>()
            
            for log in this.logs {
                
                flagSet.insert(log.flag)
                moduleSet.insert(log.module)
            }
            
            // Record
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
        guard !logs.isEmpty else { return }
        
        // Because the log volume may be large, a new thread is opened to process the log.
        DispatchQueue.global().async { [weak self] in
            
            guard let this = self else { return }
            
            defer {
                
                // Return to the main thread callback controller
                DispatchQueue.main.async(execute: completion)
            }
            
            let tmpLogs: [Log] = {
                
                if let date = this.selectedDate {
                    return this.logManager.readLogFromDisk(logDate: date) ?? []
                }
                
                return this.logManager.logs
            }()
            
            let selectModules = this.modules.filter { $0.isSelected }.map { $0.title }
            
            var flagSet = Set<Log.Flag>()
            
            if selectModules == ["ALL"] {
                
                this.logs = tmpLogs
                this.logs.forEach { flagSet.insert($0.flag) }
                
            } else {
                
                this.logs = tmpLogs.filter {
                    
                    let isSelect = selectModules.contains($0.module)
                    if isSelect { flagSet.insert($0.flag) }
                    return isSelect
                }
            }
            
            // Record
            var _flags = Array(flagSet).sorted().map { ColaCupSelectedModel(title: $0) }
            _flags.insert(ColaCupSelectedModel(isSelected: true, title: "ALL"), at: 0)
            this.flags = _flags
        }
    }
}
