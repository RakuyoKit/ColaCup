//
//  FilterDateCell.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/28.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

public class FilterDateCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    public lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        
        datePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
        
        return datePicker
    }()
}

public extension FilterDateCell {
    func setSelected(_ isSelected: Bool) {
        layer.borderColor = isSelected ? UIColor.theme.cgColor : backgroundColor?.cgColor
    }
}

// MARK: - Config

private extension FilterDateCell {
    func config() {
        if #available(iOS 13.0, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        
        layer.cornerRadius = 8
        layer.borderWidth = 1.5
        layer.borderColor = backgroundColor?.cgColor
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        addSubview(datePicker)
    }
    
    func addInitialLayout() {
        NSLayoutConstraint.activate([
            datePicker.centerYAnchor.constraint(equalTo: centerYAnchor),
            datePicker.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
}

// MARK: - Action

private extension FilterDateCell {
    @objc
    func datePickerDidChange(_ picker: UIDatePicker) {
        
    }
}
