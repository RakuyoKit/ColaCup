//
//  ColaCupSelectedModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// Model used to mark whether it is selected
public struct ColaCupSelectedModel: Equatable {
    
    public init(isSelected: Bool = false, title: String) {
        self.isSelected = isSelected
        self.title = title
    }
    
    /// Is it selected.
    public var isSelected: Bool
    
    /// The title of item.
    public let title: String
}

extension ColaCupSelectedModel {
    
    mutating func negateSelected() {
        isSelected = !isSelected
    }
}
