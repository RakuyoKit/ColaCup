//
//  BaseLogViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/24.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

open class BaseLogViewController: UIViewController {
    /// The view displayed when the log data is loaded.
    open lazy var loadingView = ColaCupLoadingView()
    
    /// The view responsible for displaying the log.
    open lazy var tableView: TableView = {
        let tableView = TableView()
        
        tableView.estimatedRowHeight = 100
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LogCell.self, forCellReuseIdentifier: "\(LogCell.self)")
        
        return tableView
    }()
    
    /// The index of the cell clicked by the user.
    private lazy var clickedIndex: IndexPath? = nil
}

extension BaseLogViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
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
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(loadingView)
    }
    
    func addInitialLayout() {
        func addConstraint(for aAxis: UIView.XAxis, toView bAxis: UIView.XAxis) -> NSLayoutConstraint {
            return tableView(xAxis: aAxis).constraint(equalTo: view(xAxis: bAxis))
        }
        
        // tableView
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            addConstraint(for: .leading, toView: .leading),
            addConstraint(for: .trailing, toView: .trailing),
        ])
        
        // loadingView
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
}

// MARK: - UITableViewDelegate

extension BaseLogViewController: UITableViewDelegate {
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        clickedIndex = indexPath
    }
}

// MARK: - UITableViewDataSource

extension BaseLogViewController: UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        assert(false, "You should override the method in the subclass and return the correct data.")
        return 1
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        assert(false, "You should override the method in the subclass and return the correct data.")
        return UITableViewCell()
    }
}

// MARK: - Tools

private extension BaseLogViewController {
    /// Cancel the selected effect of the selected Cell.
    func deselectRowIfNeeded() {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow ?? clickedIndex else { return }
        
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
