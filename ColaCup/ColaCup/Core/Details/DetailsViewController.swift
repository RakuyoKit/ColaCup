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
        
        
    }
}
