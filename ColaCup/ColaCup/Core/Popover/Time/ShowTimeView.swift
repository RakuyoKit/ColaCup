//
//  ShowTimeView.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// View to display time
open class ShowTimeView: UIControl {
    
    public init() {
        super.init(frame: .zero)
        config()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    /// Text box showing time.
    open lazy var timeLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 21)
        
        return label
    }()
    
    open override var tintColor: UIColor! {
        didSet {
            layer.borderColor = tintColor.cgColor
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            
            if isSelected {
                timeLabel.textColor = tintColor
                layer.borderWidth = 1.5
                
            } else {
                timeLabel.textColor = .black
                layer.borderWidth = 0
            }
        }
    }
}

// MARK: - Config

private extension ShowTimeView {
    
    func config() {
        
        if #available(iOS 13.0, *) {
            backgroundColor = .tertiarySystemFill
        } else {
            backgroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.5, alpha: 0.12)
        }
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            timeLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 7),
            timeLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -7)
        ])
    }
}
