//
//  DetailsPositionCell.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/25.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Used in the detail page, the cell that displays the position content
open class DetailsPositionCell: UITableViewCell {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    open lazy var iconView: UIImageView = {
        
        let view = UIImageView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .theme
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    
    open lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .darkGray
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    open lazy var valueLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .normalText
        label.textAlignment = .right
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
}

// MARK: - Config

private extension DetailsPositionCell {
    
    func config() {
        
        selectionStyle = .none
        separatorInset = UIEdgeInsets(top: 0, left: 47, bottom: 0, right: 0)
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(valueLabel)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            iconView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            iconView.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 27)
        ])
        
        iconView.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 11.5),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -11.5),
            titleLabel.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: 5)
        ])
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            valueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            valueLabel.leftAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 20),
            valueLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20)
        ])
    }
}
