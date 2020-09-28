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
    public init(log: LogModelProtocol) {
        
        self.viewModel = DetailsViewModel(log: log)
        
        super.init(style: .insetGrouped)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Used to process data.
    private let viewModel: DetailsViewModel
    
    /// Whether the tableView has been refreshed after the json has been loaded.
    private lazy var isReloaded = false
}

// MARK: - Life cycle

extension DetailsViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        
        tableView.rowHeight =  UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        tableView.separatorColor = UIColor.normalText.withAlphaComponent(0.2)
        
        DetailsCellType.allCases.forEach(tableView.register(withType:))
    }
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
        
        let model = viewModel.dataSource[indexPath.section].items[indexPath.row]
        
        let _cell = tableView.dequeueReusableCell(withIdentifier: model.type.rawValue, for: indexPath)
        
        switch model.type {
        
        case .normal:
            let cell = _cell as! DetailsNormalCell
            
            cell.textLabel?.text = model.value
            
        case .position:
            let cell = _cell as! DetailsPositionCell
            
            cell.titleLabel.text = model.title
            cell.valueLabel.text = model.value
            
            if let name = model.imageName {
                cell.iconView.image = UIImage(systemName: name)
            }
            
        case .function:
            let cell = _cell as! DetailsFunctionCell
            
            cell.titleLabel.text = model.title
            cell.valueLabel.text = model.value
            
            if let name = model.imageName {
                cell.iconView.image = UIImage(systemName: name)
            }
            
        case .json:
            let cell = _cell as! DetailsJSONCell
            
            cell.jsonView.preview(model.value) { [weak self] in
                
                guard let this = self, !this.isReloaded else { return }
                
                // The tableView needs to be refreshed to show the complete json view.
                tableView.reloadData()
                this.isReloaded = true
            }
        }
        
        return _cell
    }
}

// MARK: - Tools

fileprivate extension DetailsCellType {
    
    var cellClass: AnyClass {
        
        switch self {
        case .normal:   return DetailsNormalCell.self
        case .position: return DetailsPositionCell.self
        case .function: return DetailsFunctionCell.self
        case .json:     return DetailsJSONCell.self
        }
    }
}

fileprivate extension UITableView {
    
    func register(withType type: DetailsCellType) {
        register(type.cellClass, forCellReuseIdentifier: type.rawValue)
    }
}
