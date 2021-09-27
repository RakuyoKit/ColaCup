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
        .timeRange(title: "Time Range", values: [
            .currentPage,
            .launchToDate,
            .period(date: nil, start: 0, end: 0)
        ]),
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
}

extension FilterViewModel {
    
}
