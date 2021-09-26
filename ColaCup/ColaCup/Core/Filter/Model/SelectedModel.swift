//
//  SelectedModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// Model used to mark whether it is selected.
public struct SelectedModel<T: Equatable>: Equatable {
    public init(isSelected: Bool = false, value: T) {
        self.isSelected = isSelected
        self.value = value
    }
    
    /// Is it selected.
    public var isSelected: Bool
    
    public let value: T
}

public extension SelectedModel {
    mutating func negateSelected() {
        isSelected = !isSelected
    }
}

public extension SelectedModel where T == String {
    static let all = SelectedModel(isSelected: true, value: FilterModel.allFlag)
}
