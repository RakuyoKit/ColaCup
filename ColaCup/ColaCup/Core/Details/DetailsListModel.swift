//
//  DetailsListModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/25.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// The model used for the section in the detail page list.
public struct DetailsSectionModel {
    
    public init(title: String, items: [DetailsCellModel]) {
        self.title = title
        self.items = items
    }
    
    public init(title: String, value: String) {
        self.title = title
        self.items = [DetailsCellModel(imageName: nil, title: nil, value: value)]
    }
    
    public let title: String
    
    public let items: [DetailsCellModel]
}

/// The model used for the cell in the detail page list.
public struct DetailsCellModel {
    
    public init(imageName: String?, title: String?, value: String) {
        self.imageName = imageName
        self.title = title
        self.value = value
    }
    
    public let imageName: String?
    
    public let title: String?
    
    public let value: String
}
