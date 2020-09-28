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
        
        selectionStyle = .none
        
        contentView.addSubview(datePicker)
        
        if #available(iOS 13.4, *) {
            textLabel?.text = "Date"
            addInitialLayout()
            
        } else {
            addOldInitialLayout()
        }
    }
    
    @available(iOS 13.4, *)
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            datePicker.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -12),
        ])
        
        datePicker.setContentHuggingPriority(.required, for: .horizontal)
        datePicker.setContentHuggingPriority(.required, for: .vertical)
    }
    
    func addOldInitialLayout() {
        
        var constraints = [
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            datePicker.heightAnchor.constraint(equalToConstant: 80),
        ]
        
        if #available(iOS 11.0, *) {
            constraints.append(datePicker.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 12))
            constraints.append(datePicker.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -12))
        } else {
            constraints.append(datePicker.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 12))
            constraints.append(datePicker.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -12))
        }
        
        NSLayoutConstraint.activate(constraints)
    }
}
