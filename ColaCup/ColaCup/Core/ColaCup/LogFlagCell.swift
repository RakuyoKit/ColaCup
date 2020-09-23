//
//  LogFlagCell.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class LogFlagCell: UICollectionViewCell {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    /// Text label showing log flag
    open lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.tag = LogFlagCell.labelTag
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        label.textColor = .normalText
        
        return label
    }()
}

public extension LogFlagCell {
    
    static let labelTag = 10
}

extension LogFlagCell {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        selectedBackgroundView?.frame = CGRect(x: 0, y: 5, width: frame.width, height: frame.height - 5 * 2)
    }
}

// MARK: - Config

private extension LogFlagCell {
    
    func config() {
        
        configSelectedBackgroundView()
        addSubviews()
        addInitialLayout()
    }
    
    func configSelectedBackgroundView() {
        
        let view = UIView()
        
        view.backgroundColor = .tertiarySystemFill
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        selectedBackgroundView = view
    }
    
    func addSubviews() {
        
        contentView.addSubview(titleLabel)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            titleLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }
}
