//
//  ColaCupPopovers.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Pop-up view, including date selection and module filtering
open class ColaCupPopovers: UIViewController {
    
    /// Used to select a date to view the log of the selected date.
    open lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        return datePicker
    }()
}
