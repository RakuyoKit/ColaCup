//
//  FilterDoneButtonView.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

/// Filter page, done button at the bottom.
open class FilterDoneButtonView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    open lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        
        button.backgroundColor = .theme
        
        button.setTitle("Show Result", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        
        if #available(iOS 13.0, *) {
            button.setTitleColor(.systemBackground, for: .normal)
        } else {
            button.setTitleColor(.white, for: .normal)
        }
        
        return button
    }()
}

// MARK: - Config

private extension FilterDoneButtonView {
    func config() {
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        addSubview(doneButton)
    }
    
    func addInitialLayout() {
        var _view: (
            leadingAnchor: NSLayoutXAxisAnchor,
            trailingAnchor: NSLayoutXAxisAnchor,
            bottomAnchor: NSLayoutYAxisAnchor
        )
        
        if #available(iOS 11.0, *) {
            _view = (safeAreaLayoutGuide.leadingAnchor, safeAreaLayoutGuide.trailingAnchor, safeAreaLayoutGuide.bottomAnchor)
        } else {
            _view = (leadingAnchor, trailingAnchor, bottomAnchor)
        }
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 44),
            doneButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            doneButton.leadingAnchor.constraint(equalTo: _view.leadingAnchor, constant: 15),
            doneButton.trailingAnchor.constraint(equalTo: _view.trailingAnchor, constant: -15),
            doneButton.bottomAnchor.constraint(equalTo: _view.bottomAnchor, constant: -15),
        ])
    }
}
