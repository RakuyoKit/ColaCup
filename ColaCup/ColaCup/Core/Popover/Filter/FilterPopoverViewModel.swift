//
//  FilterPopoverswift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/16.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

public class FilterPopoverViewModel {
    
    /// Initialization method.
    ///
    /// - Parameter dataSource: The data source model of the content of the pop-up.
    public init(dataSource: FilterPopoverModel) {
        
        self.searchKeyword = dataSource.searchKeyword
        self.flags = dataSource.flags
        self.modules = dataSource.modules
    }
    
    /// Keywords used when searching.
    public var searchKeyword: String?
    
    /// Currently selected flags.
    public var flags: [SelectedModel<Log.Flag>]
    
    /// Currently selected modules.
    public var modules: [SelectedModel<String>]
    
    /// The number of fully displayed modules.
    ///
    /// Modules with more than this value will scroll to view.
    public lazy var showModuleCount = CGFloat(modules.count >= 10 ? 10 : modules.count)
    
    /// Number of modules selected.
    private lazy var selectedCount = 1
}

// MARK: - Table View

public extension FilterPopoverViewModel {
    
    /// Whether to enable the `bounces` property of the TableView.
    var isTableViewBounces: Bool { showModuleCount != CGFloat(modules.count) }
}

// MARK: - Flag

extension FilterPopoverViewModel {
    
    public typealias SelectedFlagCompletion = (_ selectedIndexs: [Int], _ deselectedIndexs: [Int]) -> Void
    
    /// Execute when the flag button is clicked.
    ///
    /// - Parameters:
    ///   - index: Index of the choosed flag.
    ///   - completion: The callback when the processing is completed will be executed on the main thread.
    public func clickFlag(at index: Int, completion: @escaping SelectedFlagCompletion) {
        
        if flags[index].isSelected {
            deselectedFlag(at: index, completion: completion)
            
        } else {
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
        
        switch flags[index].value {
        
        case "ALL":
            
            let count = flags.count
            
            for i in 1 ..< count {
                
                guard flags[i].isSelected else { continue }
                
                flags[i].isSelected = false
                
                deselectedIndexs.append(i)
            }
            
        default:
            
            if flags[0].isSelected {
                flags[0].isSelected = false
                deselectedIndexs.append(0)
            }
        }
        
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
        
        guard index != 0 else { return }
        
        flags[index].isSelected = false
        
        var selectedIndexs: [Int] = []
        
        let selectFlags = flags.filter { $0.isSelected }.map { $0.value }
        
        if selectFlags.isEmpty {
            flags[0].isSelected = true
            selectedIndexs.append(0)
        }
        
        // Return to the main thread callback controller
        DispatchQueue.main.async {
            completion(selectedIndexs, [index])
        }
    }
}

// MARK: - Module

public extension FilterPopoverViewModel {
    
    /// After selecting the module, the type of animation to be executed.
    enum AnimationType {
        
        /// Refresh the TableView directly.
        case reload
        
        /// Select `ALL` modules.
        case selectAll
        
        /// Unselect `ALL` modules.
        case unselectAll
        
        /// Select the clicked module.
        case selectClicked
        
        /// Unselect the clicked module.
        case unselectClicked
    }
    
    /// Select module.
    ///
    /// - Parameters:
    ///   - index: The index of the selected module.
    ///   - animations: Callback when the animation is executed. See ʻAnimationType` for details
    ///   - completion: The callback after processing the data.
    func selectModule(
        at index: Int,
        animations: (AnimationType) -> Void,
        completion: () -> Void
    ) {
        
        // Choose `ALL` module
        guard index != 0 else {
            
            guard !modules[0].isSelected else { return }
            
            modules[0].isSelected = true
            
            for i in 1 ..< modules.count {
                modules[i].isSelected = false
            }
            
            selectedCount = 1
            animations(.reload)
            
            completion()
            
            return
        }
        
        defer { completion() }
        
        // When selecting a module other than ʻALL`,
        // cancel the selected state of the ʻALL` module.
        if modules[0].isSelected {
            
            modules[0].isSelected = false
            selectedCount -= 1
            
            animations(.unselectAll)
        }
        
        if modules[index].isSelected {
            modules[index].isSelected = false
            selectedCount -= 1
        } else {
            modules[index].isSelected = true
            selectedCount += 1
        }
        
        animations(modules[index].isSelected ? .selectClicked : .unselectClicked)
        
        // When there is no selected module, select ʻALL`.
        guard selectedCount <= 0 else { return }
        
        modules[0].isSelected = true
        selectedCount = 1
        
        animations(.selectAll)
    }
}
