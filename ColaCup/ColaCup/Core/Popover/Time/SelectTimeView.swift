//
//  SelectTimeView.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
open class SelectTimeView: UIView {
    
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
    
    /// Title view
    open lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .normalText
        
        return label
    }()
    
    /// Used to select the time.
    open lazy var picker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .inline
        
        return datePicker
    }()
}

// MARK: - Config

@available(iOS 14.0, *)
private extension SelectTimeView {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(titleLabel)
        addSubview(picker)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            picker.leftAnchor.constraint(greaterThanOrEqualTo: titleLabel.rightAnchor, constant: 5),
            picker.rightAnchor.constraint(equalTo: rightAnchor, constant: 8),
            picker.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
        
        picker.setContentHuggingPriority(.required, for: .horizontal)
        picker.setContentHuggingPriority(.required, for: .vertical)
    }
}

