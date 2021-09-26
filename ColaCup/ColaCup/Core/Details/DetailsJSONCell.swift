//
//  DetailsJSONCell.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/25.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import JSONPreview

/// Used in the detail page, the cell that displays the json.
open class DetailsJSONCell: UITableViewCell {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    open lazy var jsonView: JSONPreview = {
    
        let view = JSONPreview()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
}

// MARK: - Config

private extension DetailsJSONCell {
    
    func config() {
        
        selectionStyle = .none
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        contentView.addSubview(jsonView)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            jsonView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            jsonView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            jsonView.topAnchor.constraint(equalTo: contentView.topAnchor),
            jsonView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
