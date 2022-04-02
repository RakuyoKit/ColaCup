//
//  TableView.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

open class TableView: UITableView {
    public init() {
        super.init(frame: .zero, style: {
            if #available(iOS 13.0, *) { return .insetGrouped }
            return .grouped
        }())
        
        translatesAutoresizingMaskIntoConstraints = false
        rowHeight = UITableView.automaticDimension
        separatorColor = UIColor.theme.withAlphaComponent(0.2)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
