//
//  ColaCupController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

/// A controller for viewing logs
open class ColaCupController: UIViewController {
    
    /// Use the log manager to initialize the controller.
    ///
    /// - Parameter logManager: The log manager is required to follow the `Storable` protocol.
    public init<T: Storable>(logManager: T.Type) {
        
        self.viewModel = ColaCupViewModel(logManager: logManager)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        datePicker.tintColor = themeColor
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
    
    /// View to display the category of logs and the category of modules.
    open lazy var categoryBar: ColaCupCategoryBar = {
        
        let categoryBar = ColaCupCategoryBar()
        
        categoryBar.translatesAutoresizingMaskIntoConstraints = false
        categoryBar.backgroundColor = .white
        
        categoryBar.modulesButton.tintColor = themeColor
        
        return categoryBar
    }()
    
    /// The view responsible for displaying the log.
    open lazy var logsView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .white
        
        return tableView
    }()
    
    /// The view displayed when the log data is loaded.
    open lazy var loadingView: ColaCupLoadingView = {
        
        let view = ColaCupLoadingView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        
        view.activityIndicator.color = themeColor
        
        return view
    }()
    
    /// Theme color. The default is a custom red.
    open lazy var themeColor = UIColor(red:0.91, green:0.13, blue:0.23, alpha:1.00)
    
    /// Used to process data
    public let viewModel: ColaCupViewModel
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
        
        loadingView.isHidden = false
    }
}

// MARK: - Config

private extension ColaCupController {
    
    func addSubviews() {
        
        view.addSubview(headerView)
        view.addSubview(logsView)
        view.addSubview(loadingView)
        
        headerView.addSubview(searchBar)
        headerView.addSubview(categoryBar)
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
        
        // categoryBar
        NSLayoutConstraint.activate([
            categoryBar.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            categoryBar.leftAnchor.constraint(equalTo: searchBar.leftAnchor),
            categoryBar.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -7),
            categoryBar.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            
            categoryBar.heightAnchor.constraint(equalToConstant: 37)
        ])
        
//        categoryBar.setContentHuggingPriority(.required, for: .vertical)
        
        // logsView
        NSLayoutConstraint.activate([
            logsView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            logsView.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            logsView.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            logsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // loadingView
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 90),
            loadingView.heightAnchor.constraint(equalTo: loadingView.widthAnchor),
        ])
    }
}

// MARK: - UINavigationControllerDelegate

extension ColaCupController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let isHide = viewController is ColaCupController
        navigationController.setNavigationBarHidden(isHide, animated: animated)
    }
}
