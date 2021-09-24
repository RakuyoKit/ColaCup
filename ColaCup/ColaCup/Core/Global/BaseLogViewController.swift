//
//  BaseLogViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/24.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

open class BaseLogViewController: UITableViewController {
    public init() {
        super.init(style: {
            if #available(iOS 13.0, *) { return .insetGrouped }
            return .grouped
        }())
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The view displayed when the log data is loaded.
    open lazy var loadingView = ColaCupLoadingView()
}

extension BaseLogViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configTableView()
        addSubviews()
        addInitialLayout()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Cancel the selected effect of the selected Cell.
        deselectRowIfNeeded()
    }
    
    open override var shouldAutorotate: Bool { true }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
}

// MARK: - Config

private extension BaseLogViewController {
    func configTableView() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorColor = UIColor.theme.withAlphaComponent(0.2)
        tableView.register(LogCell.self, forCellReuseIdentifier: "LogCell")
    }
    
    func addSubviews() {
        view.addSubview(loadingView)
    }
    
    func addInitialLayout() {
        // loadingView
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - Tools

private extension BaseLogViewController {
    /// Cancel the selected effect of the selected Cell.
    func deselectRowIfNeeded() {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        guard let coordinator = transitionCoordinator else {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
            return
        }
        
        coordinator.animate(
            alongsideTransition: { _ in
                self.tableView.deselectRow(at: selectedIndexPath, animated: true)
            },
            completion: { context in
                guard context.isCancelled else { return }
                self.tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        )
    }
}
