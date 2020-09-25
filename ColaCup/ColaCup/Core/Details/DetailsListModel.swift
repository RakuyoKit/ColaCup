//
//  DetailsListModel.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/25.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import Foundation

/// Model used for detail page listing
public struct DetailsListModel {
    
    init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    public let title: String
    
    public let value: String
}
