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
    public var flags: [ColaCupSelectedModel<Log.Flag>]
    
    /// Currently selected modules.
    public var modules: [ColaCupSelectedModel<String>]
    
    /// The number of fully displayed modules.
    ///
    /// Modules with more than this value will scroll to view.
    public lazy var showModuleCount = CGFloat(modules.count >= 10 ? 10 : modules.count)
    
    /// Number of modules selected.
    private lazy var selectedCount = 1
}

public extension FilterPopoverViewModel {
    
    var isTableViewBounces: Bool { showModuleCount != CGFloat(modules.count) }
}

public extension FilterPopoverViewModel {
    
    enum AnimationType {
        
        case reload
        
        case checkAll
        
        case uncheckAll
        
        case checkClicked
        
        case uncheckClicked
    }
    
    func selectModule(at index: Int, animations: (AnimationType) -> Void) {
        
        // Choose `ALL` module
        guard index != 0 else {
            
            guard !modules[0].isSelected else { return }
            
            modules[0].isSelected = true
            
            for i in 1 ..< modules.count {
                modules[i].isSelected = false
            }
            
            selectedCount = 1
            animations(.reload)
            
            return
        }
        
        // When selecting a module other than ʻALL`,
        // cancel the selected state of the ʻALL` module.
        if modules[0].isSelected {
            
            modules[0].isSelected = false
            selectedCount -= 1
            
            animations(.uncheckAll)
        }
        
        if modules[index].isSelected {
            modules[index].isSelected = false
            selectedCount -= 1
        } else {
            modules[index].isSelected = true
            selectedCount += 1
        }
        
        animations(modules[index].isSelected ? .checkClicked : .uncheckClicked)
        
        // When there is no selected module, select ʻALL`.
        guard selectedCount <= 0 else { return }
        
        modules[0].isSelected = true
        selectedCount = 1
        
        animations(.checkAll)
    }
}
