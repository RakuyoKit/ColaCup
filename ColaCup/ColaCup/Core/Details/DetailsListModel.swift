//
//  DetailsListModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/25.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// The model used to configure the detail list.
public struct DetailsSectionModel {
    public init(title: String?, items: [DetailsCellModel]) {
        self.title = title
        self.items = items
    }
    
    public init(type: DetailsCellType = .normal, title: String?, value: String) {
        self.title = title
        self.items = [DetailsCellModel(type: type, value: value)]
    }
    
    public let title: String?
    
    public var items: [DetailsCellModel]
}

/// Type of detail page cell
public enum DetailsCellType: String, CaseIterable {
    /// Used to show general content
    case normal
    
    /// Used to show log position
    case position
    
    /// Used to show function names
    case function
    
    /// Used to show json
    case json
}

/// The model used for the cell in the detail page list.
public struct DetailsCellModel {
    public init(
        type: DetailsCellType = .normal,
        image: String? = nil,
        title: String? = nil,
        value: String
    ) {
        self.type = type
        self.imageName = image
        self.title = title
        self.value = value
    }
    
    public let type: DetailsCellType
    
    public let imageName: String?
    
    public let title: String?
    
    public var value: String
}
