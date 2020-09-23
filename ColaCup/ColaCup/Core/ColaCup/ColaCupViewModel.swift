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
    
    /// Only include the flag used in the currently viewed log. Will not repeat.
    public lazy var flags: [ColaCupSelectedModel] = []
    
    /// Only include the module in the currently viewed log. Will not repeat.
    public lazy var modules: [ColaCupSelectedModel] = []
    
    /// Log manager.
    private let logManager: Storable.Type
}

public extension ColaCupViewModel {
    
    /// Process log data.
    ///
    /// - Parameters:
    ///   - date: The date of the log to be processed, if it is nil, it will be obtained directly from the log manager.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    func processLogs(date: Date? = nil, completion: @escaping () -> Void) {
        
        let logs: [Log] = {
            
            if let date = date {
                return logManager.readLogFromDisk(logDate: date) ?? []
            }
            
            return logManager.logs
        }()
        
        guard !logs.isEmpty else {
            completion()
            return
        }
        
        // Because the log volume may be large, a new thread is opened to process the log.
        DispatchQueue.global().async { [weak self] in
            
            guard let this = self else { return }
            
            var flagSet = Set<Log.Flag>()
            var moduleSet = Set<String>()
            
            for log in logs {
                
                flagSet.insert(log.flag)
                moduleSet.insert(log.module)
            }
            
            let all = ColaCupSelectedModel(isSelected: true, title: "ALL")
            
            // Record
            var _flags = Array(flagSet).sorted().map { ColaCupSelectedModel(title: $0) }
            _flags.insert(all, at: 0)
            this.flags = _flags
            
            var _modules = Array(moduleSet).sorted().map { ColaCupSelectedModel(title: $0) }
            _modules.insert(all, at: 0)
            this.modules = _modules
            
            // Return to the main thread callback controller
            DispatchQueue.main.async(execute: completion)
        }
    }
}
