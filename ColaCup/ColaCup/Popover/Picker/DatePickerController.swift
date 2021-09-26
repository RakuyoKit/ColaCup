//
//  DatePickerController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/11/2.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

public protocol DatePickerDelegate: PickerDelegate {
    
    /// Called when date is selected.
    ///
    /// - Parameters:
    ///   - controller: `DatePickerController`
    ///   - date: Selected date
    func datePicker(_ controller: DatePickerController, didSelectDate date: Date)
}

open class DatePickerController: BasePickerController {
    
    /// Delegate.
    public weak var delegate: DatePickerDelegate? = nil
    
    /// The picker used to select the date.
    open lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        
        return datePicker
    }()
}

extension DatePickerController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            datePicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            datePicker.leftAnchor.constraint(equalTo: view.leftAnchor),
            datePicker.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.pickerWillDisappear(self)
    }
}

// MARK: - Action

extension DatePickerController {
    
    @objc open override func doneButtonDidClick() {
        super.doneButtonDidClick()
        
        delegate?.datePicker(self, didSelectDate: datePicker.date)
    }
}
