//
//  FilterViewModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

/// Used to handle filtering logic
public class FilterViewModel {
    /// Initializes with the currently selected filter condition.
    ///
    /// - Parameters:
    ///   - filter: currently selected filter condition.
    ///   - flags: The set of all logs currently displayed, with the flags they belong to.
    ///   - modules: The set of all logs currently displayed, with the module they belong to.
    public init(
        selectedFilter filter: FilterModel,
        allFlags flags: [Flag],
        allModules modules: [String]
    ) {
        self.selectedFilter = filter
        self.allFlags = flags
        self.allModules = modules
    }
    
    /// List data source.
    public lazy var dataSource: [FilterSection] = [
        .sort(title: "Sort", values: [.positive, .negative]),
        .timeRange(title: "Time Range", values: [.currentPage, .launchToDate, .oneDate(date: nil)]),
        .flag(title: "Flag", values: allFlags),
        .module(title: "Module", values: allModules)
    ]
    
    /// currently selected filter condition.
    private(set) var selectedFilter: FilterModel
    
    /// The set of all logs currently displayed, with the flags they belong to.
    private let allFlags: [Flag]
    
    /// The set of all logs currently displayed, with the module they belong to.
    private let allModules: [String]
}

public extension FilterViewModel {
    /// Reset filter items
    func reset() {
        selectedFilter = FilterModel()
    }
    
    func updateSort(_ sort: Sort) {
        selectedFilter.sort = sort
    }
    
    func updateSelectedFlag(_ flag: Flag) {
        if flag == FilterModel.allFlag {
            // 无法反选 ALL
            if selectedFilter.flags.contains(flag) { return }
            
            selectedFilter.flags.removeAll()
            selectedFilter.flags.insert(flag)
            
        } else {
            // 包含则移除，不包含则加入
            if selectedFilter.flags.contains(flag) {
                selectedFilter.flags.remove(flag)
            } else {
                selectedFilter.flags.insert(flag)
            }
            
            if selectedFilter.flags.isEmpty {
                selectedFilter.flags.insert(FilterModel.allFlag)
            } else {
                selectedFilter.flags.remove(FilterModel.allFlag)
            }
        }
    }
    
    func updateSelectedModule(_ module: String) {
        if module == FilterModel.allFlag {
            // 无法反选 ALL
            if selectedFilter.modules.contains(module) { return }
            
            selectedFilter.modules.removeAll()
            selectedFilter.modules.insert(module)
            
        } else {
            // 包含则移除，不包含则加入
            if selectedFilter.modules.contains(module) {
                selectedFilter.modules.remove(module)
            } else {
                selectedFilter.modules.insert(module)
            }
            
            if selectedFilter.modules.isEmpty {
                selectedFilter.modules.insert(FilterModel.allFlag)
            } else {
                selectedFilter.modules.remove(FilterModel.allFlag)
            }
        }
    }
}
