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
        
        if case .oneDate(let date) = selectedFilter.timeRange {
            self.selectedDate = date
        }
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
    
    /// The date currently selected by the user.
    private(set) lazy var selectedDate: Date? = nil
    
    /// The set of all logs currently displayed, with the flags they belong to.
    private let allFlags: [Flag]
    
    /// The set of all logs currently displayed, with the module they belong to.
    private let allModules: [String]
}

public extension FilterViewModel {
    /// Reset filter items
    func reset() {
        selectedFilter = FilterModel()
        selectedDate = nil
    }
    
    func updateSort(to sort: Sort) {
        selectedFilter.sort = sort
    }
    
    func updateTimeRange(to range: FilterTimeRange) {
        selectedFilter.timeRange = range
        
        if case .oneDate(let date) = range {
            selectedDate = date
        }
    }
    
    func updateSelectedFlag(to flag: Flag) {
        if flag == FilterModel.allFlag {
            // Unable to deselect "ALL"
            if selectedFilter.flags.contains(flag) { return }
            
            selectedFilter.flags.removeAll()
            selectedFilter.flags.insert(flag)
            
        } else {
            // Remove if included, add if not
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
    
    func updateSelectedModule(to module: String) {
        if module == FilterModel.allFlag {
            // Unable to deselect "ALL"
            if selectedFilter.modules.contains(module) { return }
            
            selectedFilter.modules.removeAll()
            selectedFilter.modules.insert(module)
            
        } else {
            // Remove if included, add if not
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

extension FilterViewModel {
    /// Cache `DateFormatter` object.
    private static let formatter = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
    }()
    
    public func description(of sort: Sort) -> String {
        switch sort {
        case .positive: return "Positive"
        case .negative: return "Negative"
        }
    }
    
    public func description(of timeRange: FilterTimeRange) -> String {
        switch timeRange {
        case .currentPage: return "Current Page"
        case .launchToDate: return "From launch to now"
        case .oneDate:
            guard let _date = selectedDate else { return "One Date" }
            return Self.formatter.string(from: _date)
        }
    }
}
