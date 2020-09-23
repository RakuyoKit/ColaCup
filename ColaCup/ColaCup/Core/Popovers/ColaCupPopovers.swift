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
    
    /// Initialize the pop-up window controller with the date and module of the currently viewed log.
    ///
    /// - Parameters:
    ///   - date: The date of the currently viewed log.
    ///   - modules: The modules to which the currently viewed log belongs.
    init(date: Date, modules: [ColaCupSelectedModel]) {
        self.date = date
        self.modules = modules
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The date of the currently viewed log.
    public let date: Date
    
    /// The modules to which the currently viewed log belongs.
    public let modules: [ColaCupSelectedModel]
    
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
