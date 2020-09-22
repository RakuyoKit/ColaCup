//
//  ColaCupController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// A controller for viewing logs
open class ColaCupController: UIViewController {
    
    /// Top view of the page. Include search box and label selection view.
    open lazy var headerView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        
        return view
    }()
    
    /// Used to select a date to view the log of the selected date.
    open lazy var datePicker: UIDatePicker = {
        
        let datePicker = UIDatePicker()
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.backgroundColor = .clear
        
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        
        return datePicker
    }()
    
    /// Used to search logs.
    open lazy var searchBar: ColaCupSearchBar = {
        
        let searchBar = ColaCupSearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.headerView = datePicker
        
        return searchBar
    }()
}

// MARK: - Life cycle

extension ColaCupController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Solve the problem of hidden navigation bar
        navigationController?.delegate = self
        
        view.backgroundColor = UIColor(red:0.98, green:0.95, blue:0.93, alpha:1.00)
        
        addSubviews()
        
        addInitialLayout()
    }
}

// MARK: - Config

private extension ColaCupController {
    
    func addSubviews() {
        
        view.addSubview(headerView)
        
        headerView.addSubview(searchBar)
    }
    
    func addInitialLayout() {
        
        // headerView
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            headerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10)
        ])
        
        headerView.setContentHuggingPriority(.required, for: .vertical)
        
        // searchBar
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 2),
            searchBar.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 10),
            searchBar.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -1)
        ])
        
        searchBar.setContentHuggingPriority(.required, for: .vertical)
    }
}

// MARK: - UINavigationControllerDelegate

extension ColaCupController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let isHide = viewController is ColaCupController
        navigationController.setNavigationBarHidden(isHide, animated: animated)
    }
}
