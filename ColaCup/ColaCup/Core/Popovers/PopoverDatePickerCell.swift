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
        } else {
            
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
        
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.rightAnchor.constraint(equalTo: {
                guard #available(iOS 11.0, *) else {
                    return contentView.rightAnchor
                }
                return contentView.safeAreaLayoutGuide.rightAnchor
            }(), constant: -12),
        ])
        
        datePicker.setContentHuggingPriority(.required, for: .horizontal)
        datePicker.setContentHuggingPriority(.required, for: .vertical)
    }
}
