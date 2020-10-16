//
//  ColaCupSelectedModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// Model used to mark whether it is selected.
public struct ColaCupSelectedModel<T: Equatable>: Equatable {
    
    public init(isSelected: Bool = false, value: T) {
        self.isSelected = isSelected
        self.value = value
    }
    
    /// Is it selected.
    public var isSelected: Bool
    
    public let value: T
}

extension ColaCupSelectedModel {
    
    mutating func negateSelected() {
        isSelected = !isSelected
    }
}
