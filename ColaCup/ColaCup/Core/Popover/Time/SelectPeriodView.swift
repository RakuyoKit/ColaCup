//
//  SelectPeriodView.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

@available(iOS 14.0, *)
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
    
    /// Title view
    open lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .normalText
        label.text = "Period"
        
        return label
    }()
    
    /// Used to select the start time.
    open lazy var startPicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "en_GB")
        
        return datePicker
    }()
    
    /// Preposition label
    open lazy var prepositionLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .normalText
        label.text = "to"
        
        return label
    }()
    
    /// Used to select the end time.
    open lazy var endPicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.datePickerMode = .time
        datePicker.preferredDatePickerStyle = .inline
        datePicker.locale = Locale(identifier: "en_GB")
        
        return datePicker
    }()
}

// MARK: - Config

@available(iOS 14.0, *)
private extension SelectPeriodView {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(titleLabel)
        addSubview(startPicker)
        addSubview(prepositionLabel)
        addSubview(endPicker)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            endPicker.rightAnchor.constraint(equalTo: rightAnchor, constant: 7),
            endPicker.topAnchor.constraint(equalTo: topAnchor),
            endPicker.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        endPicker.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            prepositionLabel.rightAnchor.constraint(equalTo: endPicker.leftAnchor),
            prepositionLabel.topAnchor.constraint(equalTo: topAnchor),
            prepositionLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        prepositionLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            startPicker.rightAnchor.constraint(equalTo: prepositionLabel.leftAnchor),
            startPicker.topAnchor.constraint(equalTo: topAnchor),
            startPicker.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        startPicker.setContentHuggingPriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.rightAnchor.constraint(greaterThanOrEqualTo: startPicker.leftAnchor),
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
    }
}

