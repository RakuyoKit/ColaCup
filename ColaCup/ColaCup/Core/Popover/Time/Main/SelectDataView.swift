//
//  SelectDataView.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

@available(iOS 13.4, *)
open class SelectDataView: UIView {
    
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
    
    /// Used to select a date to view the log of the selected date.
    open lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        
        return datePicker
    }()
}

// MARK: - Config

@available(iOS 13.4, *)
private extension SelectDataView {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(titleLabel)
        addSubview(datePicker)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            datePicker.rightAnchor.constraint(equalTo: rightAnchor),
            datePicker.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        datePicker.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: datePicker.centerYAnchor)
        ])
        
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
}
