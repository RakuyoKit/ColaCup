//
//  FilterPopoverModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

/// Data source model for `FilterPopover`.
public struct FilterPopoverModel {
    
    public init(
        searchKeyword: String? = nil,
        selectedFlags: [SelectedModel<Log.Flag>] = [],
        selectedModules: [SelectedModel<String>] = []
    ) {
        self.searchKeyword = searchKeyword
        self.flags = selectedFlags
        self.modules = selectedModules
    }
    
    /// Keywords used when searching.
    public var searchKeyword: String?
    
    /// Currently selected flags.
    public var flags: [SelectedModel<Log.Flag>]
    
    /// Currently selected modules.
    public var modules: [SelectedModel<String>]
}
