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
    
    private lazy var _datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Date()
        
        datePicker.subviews[0].subviews[0].subviews[0].alpha = 0
        
        if #available(iOS 13.0, *) {
            datePicker.tintColor = .label
        }
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .compact
            datePicker.addTarget(self, action: #selector(datePickerDidEditingEnd(_:)), for: .editingDidEnd)
        }
        
        return datePicker
    }()
    
    @available(iOS, obsoleted: 13.4, message: "The `datePicker` will be used to display the date.")
    public lazy var label: UILabel = {
        let label = UILabel()
        
        label.textColor = .labelColor
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.preferredFont(forTextStyle: .body)
        
        return label
    }()
    
    /// The callback after the user selects the date.
    private lazy var _completion: ((Date?) -> Void)? = nil
}

public extension FilterDateCell {
    var datePicker: UIDatePicker {
        @available(iOS 13.4, *)
        get { _datePicker }
        set { _datePicker = newValue }
    }
    
    /// The callback after the user selects the date.
    var completion: ((Date?) -> Void)? {
        @available(iOS 13.4, *)
        get { _completion }
        set { _completion = newValue }
    }
    
    @available(iOS 13.4, *)
    func setDate(_ _date: Date?) {
        guard let date = _date, datePicker.date != date else { return }
        datePicker.date = date
    }
    
    func setSelected(_ isSelected: Bool) {
        layer.borderColor = isSelected ? UIColor.theme.cgColor : backgroundColor?.cgColor
    }
}

// MARK: - Config

private extension FilterDateCell {
    func config() {
        backgroundColor = .systemBackgroundColor
        
        layer.cornerRadius = 8
        layer.borderWidth = 1.5
        layer.borderColor = backgroundColor?.cgColor
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        if #available(iOS 13.4, *) {
            contentView.addSubview(datePicker)
        } else {
            contentView.addSubview(label)
        }
    }
    
    func addInitialLayout() {
        if #available(iOS 13.4, *) {
            NSLayoutConstraint.activate([
                datePicker.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                datePicker.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            ])
        }
    }
}

// MARK: - Action

private extension FilterDateCell {
    @available(iOS 13.4, *) @objc
    func datePickerDidEditingEnd(_ picker: UIDatePicker) {
        completion?(picker.date)
    }
}
