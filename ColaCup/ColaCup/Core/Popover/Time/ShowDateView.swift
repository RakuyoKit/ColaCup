//
//  ShowDateView.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/11/2.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// View to display date.
@available(iOS, deprecated: 13.4)
open class ShowDateView: UIControl {
    
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
    
    /// Text label showing date.
    open lazy var dateLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        
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
                dateLabel.textColor = tintColor
                layer.borderWidth = 1.5
                
            } else {
                dateLabel.textColor = .black
                layer.borderWidth = 0
            }
        }
    }
}

// MARK: - Config

private extension ShowDateView {
    
    func config() {
        
        if #available(iOS 13.0, *) {
            backgroundColor = .tertiarySystemFill
        } else {
            backgroundColor = UIColor(red: 0.46, green: 0.46, blue: 0.5, alpha: 0.12)
        }
        
        layer.cornerRadius = 8
        layer.masksToBounds = true
        
        addSubview(dateLabel)
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 7),
            dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -7)
        ])
    }
}
