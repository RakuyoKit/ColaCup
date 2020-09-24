//
//  LogFlagButton.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/24.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Log flag button.
open class LogFlagButton: UIControl {
    
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
    
    /// The background view displayed in the selected state.
    open lazy var selectedBackgroundView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        view.backgroundColor = .tertiarySystemFill
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        return view
    }()
    
    /// Text label showing log flag
    open lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        label.textColor = .normalText
        
        return label
    }()
    
    open override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.selectedBackgroundView.isHidden = !self.isSelected
            }
        }
    }
}

// MARK: - Config

private extension LogFlagButton {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(selectedBackgroundView)
        addSubview(titleLabel)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            selectedBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            selectedBackgroundView.leftAnchor.constraint(equalTo: leftAnchor),
            selectedBackgroundView.rightAnchor.constraint(equalTo: rightAnchor),
            selectedBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
}
