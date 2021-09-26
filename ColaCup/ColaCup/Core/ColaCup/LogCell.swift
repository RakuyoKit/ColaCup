//
//  LogCell.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/24.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class LogCell: UITableViewCell {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    open lazy var flagLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = UIColor(red:0.73, green:0.26, blue:0.18, alpha:1.00)
        label.font = UIFont.systemFont(ofSize: label.font.pointSize - 2)
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .natural
        label.numberOfLines = 1
        
        return label
    }()
    
    open lazy var timeLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = UIColor(red:0.73, green:0.26, blue:0.18, alpha:1.00)
        label.font = UIFont.systemFont(ofSize: label.font.pointSize - 2)
        label.textAlignment = .natural
        label.numberOfLines = 1
        
        return label
    }()
    
    open lazy var logLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .normalText
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 2
        
        return label
    }()
}

// MARK: - Config

private extension LogCell {
    
    func config() {
        
        separatorInset = .zero
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        contentView.addSubview(flagLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(logLabel)
    }
    
    func addInitialLayout() {
        
        // flagLabel
        NSLayoutConstraint.activate([
            flagLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            flagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
        ])
        
        flagLabel.setContentHuggingPriority(.required, for: .vertical)
        
        // timeLabel
        NSLayoutConstraint.activate([
            timeLabel.centerYAnchor.constraint(equalTo: flagLabel.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: flagLabel.leadingAnchor, constant: 10),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
        timeLabel.setContentHuggingPriority(.required, for: .horizontal)
        timeLabel.setContentHuggingPriority(.required, for: .vertical)
        
        // logLabel
        NSLayoutConstraint.activate([
            logLabel.topAnchor.constraint(equalTo: flagLabel.bottomAnchor, constant: 10),
            logLabel.leadingAnchor.constraint(equalTo: flagLabel.leadingAnchor),
            logLabel.trailingAnchor.constraint(equalTo: timeLabel.trailingAnchor),
            logLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            
            // Maximum height of two rows
            logLabel.heightAnchor.constraint(lessThanOrEqualToConstant: ceil(logLabel.font.lineHeight * 2))
        ])
    }
}
