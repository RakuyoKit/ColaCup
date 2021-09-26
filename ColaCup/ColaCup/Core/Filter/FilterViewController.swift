//
//  FilterViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

/// The controller used to select the filtering conditions.
open class FilterViewController: UIViewController {
    /// Initializes with the currently selected filter condition.
    ///
    /// - Parameter model: currently selected filter condition.
    public init(selectedFilter model: FilterModel) {
        self.viewModel = FilterViewModel(selectedFilter: model)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let viewModel: FilterViewModel
}

extension FilterViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
