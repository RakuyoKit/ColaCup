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
    
    /// Used to process data.
    private let viewModel: FilterViewModel
}

// MARK: - Life cycle

extension FilterViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationBar()
    }
}

// MARK: - Config

private extension FilterViewController {
    func configNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        navigationItem.title = "Filter"
        navigationController?.navigationBar.tintColor = .theme
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidClick(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetButtonDidClick(_:)))
    }
}

// MARK: - Action

extension FilterViewController {
    @objc
    open func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    open func resetButtonDidClick(_ sender: UIBarButtonItem) {
        
    }
}
