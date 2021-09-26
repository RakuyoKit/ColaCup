//
//  DetailsNormalCell.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/25.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Used in the detail page, the cell that displays general content.
open class DetailsNormalCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
}

// MARK: - Config

private extension DetailsNormalCell {
    func config() {
        selectionStyle = .none
        
        textLabel?.numberOfLines = 0
        textLabel?.textColor = .normalText
        textLabel?.textAlignment = .natural
        textLabel?.lineBreakMode = .byTruncatingTail
    }
}
