//
//  PopoverDatePickerCell.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// The cell used to display the date picker
open class PopoverDatePickerCell: UITableViewCell {
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        config()
    }
    
    /// Used to select a date to view the log of the selected date.
    open lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        
        return datePicker
    }()
}

// MARK: - Config

private extension PopoverDatePickerCell {
    
    func config() {
        
        textLabel?.text = "Date"
        selectionStyle = .none
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        contentView.addSubview(datePicker)
    }
    
    func addInitialLayout() {
        
        var constraints: [NSLayoutConstraint] = []
        
        if #available(iOS 13.4, *) {
            constraints.append(datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor))
        } else {
            constraints.append(datePicker.topAnchor.constraint(equalTo: contentView.topAnchor))
            constraints.append(datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))
            constraints.append(datePicker.heightAnchor.constraint(equalToConstant: 80))
            constraints.append(datePicker.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.65))
        }
        
        if #available(iOS 11.0, *) {
            constraints.append(datePicker.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -12))
        } else {
            constraints.append(datePicker.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12))
        }
        
        NSLayoutConstraint.activate(constraints)
        
        if #available(iOS 13.4, *) {
            datePicker.setContentHuggingPriority(.required, for: .horizontal)
            datePicker.setContentHuggingPriority(.required, for: .vertical)
        }
    }
}
