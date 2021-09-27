//
//  DateAlertController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/27.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

/// Alert controller for time selection.
public class DateAlertController: UIViewController {
    /// Use the currently selected date for initialization.
    ///
    /// - Parameter date: The date currently selected by the user.
    public init(date: Date?) {
        self.date = date ?? Date()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.tintColor = .theme
        
        datePicker.datePickerMode = .date
        datePicker.date = date
        datePicker.maximumDate = Date()
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        } else if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        
        datePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
        
        return datePicker
    }()
    
    /// The callback after the user selects the date.
    public lazy var completion: ((Date?) -> Void)? = nil
    
    /// The date currently selected by the user.
    private var date: Date
}

// MARK: - Life cycle

extension DateAlertController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        configNavigationBar()
        
        addSubviews()
        addInitialLayout()
    }
}

// MARK: - Config

private extension DateAlertController {
    func configNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        navigationItem.title = "Select Date"
        navigationController?.navigationBar.tintColor = .theme
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidClick(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidClick(_:)))
    }
    
    func addSubviews() {
        view.addSubview(datePicker)
    }
    
    func addInitialLayout() {
        datePicker.heightAnchor.constraint(equalToConstant: 365).isActive = true
        
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
                datePicker.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            ])
        } else {
            NSLayoutConstraint.activate([
                datePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
                datePicker.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                datePicker.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }
    }
}

// MARK: - Action

private extension DateAlertController {
    @objc
    func datePickerDidChange(_ picker: UIDatePicker) {
        date = picker.date
    }
    
    /// Cancel button click events
    @objc
    func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Done button click events
    @objc
    func doneButtonDidClick(_ sender: UIBarButtonItem) {
        completion?(date)
        dismiss(animated: true, completion: nil)
    }
}
