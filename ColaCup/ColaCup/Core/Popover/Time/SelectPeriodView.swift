//
//  SelectPeriodView.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// View to show time period.
open class SelectPeriodView: UIView {
    
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
    
    /// Title view.
    open lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textAlignment = .left
        label.textColor = .normalText
        
        return label
    }()
    
    /// View showing start time.
    open lazy var startView: ShowTimeView = {
        
        let view = ShowTimeView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .theme
        
        return view
    }()
    
    /// A preposition label displayed between the start time and the end time.
    open lazy var prepositionLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "to"
        label.textAlignment = .center
        label.textColor = .normalText
        
        return label
    }()
    
    /// View showing end time.
    open lazy var endView: ShowTimeView = {
        
        let view = ShowTimeView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = .theme
        
        return view
    }()
}

// MARK: - Config

private extension SelectPeriodView {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(titleLabel)
        addSubview(startView)
        addSubview(prepositionLabel)
        addSubview(endView)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            endView.widthAnchor.constraint(equalToConstant: 73),
            endView.centerYAnchor.constraint(equalTo: centerYAnchor),
            endView.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        
        endView.setContentHuggingPriority(.required, for: .horizontal)
        endView.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            prepositionLabel.centerYAnchor.constraint(equalTo: endView.centerYAnchor),
            prepositionLabel.rightAnchor.constraint(equalTo: endView.leftAnchor, constant: -4)
        ])
        
        prepositionLabel.setContentHuggingPriority(.required, for: .horizontal)
        prepositionLabel.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            startView.widthAnchor.constraint(equalTo: endView.widthAnchor),
            startView.centerYAnchor.constraint(equalTo: endView.centerYAnchor),
            startView.rightAnchor.constraint(equalTo: prepositionLabel.leftAnchor, constant: -4)
        ])
        
        startView.setContentHuggingPriority(.required, for: .horizontal)
        startView.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: endView.centerYAnchor),
            titleLabel.rightAnchor.constraint(equalTo: startView.leftAnchor, constant: -3)
        ])
        
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        
        
//        CompressionResistance
    }
}
