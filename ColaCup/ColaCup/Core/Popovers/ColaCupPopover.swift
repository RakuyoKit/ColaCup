//
//  ColaCupPopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Pop-up view, including date selection and module filtering.
open class ColaCupPopover: UIViewController {
    
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
    public var date: Date
    
    /// The modules to which the currently viewed log belongs.
    public var modules: [ColaCupSelectedModel]
    
    /// TableView showing the list of modules
    open lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PopoverDatePickerCell.self, forCellReuseIdentifier: "PopoverDatePickerCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        return tableView
    }()
}

// MARK: - Life cycle

extension ColaCupPopover {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        addSubviews()
        
        addInitialLayout()
    }
}

// MARK: - Config

private extension ColaCupPopover {
    
    func addSubviews() {
        
        view.addSubview(tableView)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - UITableViewDelegate

extension ColaCupPopover: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        modules[indexPath.row].isSelected = !modules[indexPath.row].isSelected
        
        tableView.cellForRow(at: indexPath)?.accessoryType = modules[indexPath.row].isSelected ? .checkmark : .none
    }
}

// MARK: - UITableViewDataSource

extension ColaCupPopover: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : modules.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PopoverDatePickerCell", for: indexPath) as! PopoverDatePickerCell
            
            cell.datePicker.date = date
            
            return cell
        }
        
        let model = modules[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.textLabel?.text = model.title
        cell.accessoryType = model.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        
        return cell
    }
}
