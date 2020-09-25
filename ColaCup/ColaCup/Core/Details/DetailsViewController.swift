//
//  DetailsViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/22.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

/// Controller that displays the details of the log
open class DetailsViewController: UITableViewController {
    
    /// Initialize with log data.
    ///
    /// - Parameter log: The detailed log data to be viewed.
    public init(log: Log) {
        
        self.viewModel = DetailsViewModel(log: log)
        
        super.init(style: .insetGrouped)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Used to process data.
    private let viewModel: DetailsViewModel
}

// MARK: - Life cycle

extension DetailsViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        
        tableView.rowHeight =  UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        tableView.separatorColor = UIColor.theme.withAlphaComponent(0.2)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
}

// MARK: - UITableViewDelegate

extension DetailsViewController {
    
    
}

// MARK: - UITableViewDataSource

extension DetailsViewController {
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.dataSource.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource[section].items.count
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return viewModel.dataSource[section].title
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        let model = viewModel.dataSource[indexPath.section].items[indexPath.row]
        
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = model.value
        
        return cell
    }
}
