//
//  SearchResultViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/24.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

public protocol SearchResultViewControllerDelegate: NSObjectProtocol {
    /// Triggered when searching, used to return search results.
    ///
    /// - Parameters:
    ///   - resultController: The controller that currently displays the search results.
    ///   - keyword: User-entered search keywords.
    ///   - result: Closures for getting search results.
    func searchResult(
        _ resultController: SearchResultViewController,
        search keyword: String,
        result: @escaping ([[LogModelProtocol]]) -> Void
    )
    
    /// Triggered when clicking on search results.
    ///
    /// - Parameters:
    ///   - resultController: The controller that currently displays the search results.
    ///   - log: Clicked log.
    func searchResult(_ resultController: SearchResultViewController, didClickResult log: LogModelProtocol)
}

public protocol SearchResultViewControllerScrollDelegate: NSObjectProtocol {
    /// Called when the TableView is slid.
    ///
    /// - Parameter resultController: The controller that currently displays the search results.
    func searchResultDidScroll(_ resultController: SearchResultViewController)
}

/// Controller for displaying search results.
open class SearchResultViewController: BaseLogViewController {
    public weak var delegate: SearchResultViewControllerDelegate? = nil
    
    public weak var scrollDelegate: SearchResultViewControllerScrollDelegate? = nil
    
    private lazy var dataSource: [[LogModelProtocol]] = []
    
    /// The last search entered.
    private lazy var lastKeyword: String = ""
}

// MARK: - UISearchResultsUpdating

extension SearchResultViewController: UISearchResultsUpdating {
    open func updateSearchResults(for searchController: UISearchController) {
        guard let keyword = searchController.searchBar.text,
              keyword != lastKeyword else { return }
        
        loadingView.show()
        
        lastKeyword = keyword
        delegate?.searchResult(self, search: keyword) { [weak self] in
            guard let this = self else { return }
            
            this.dataSource = $0
            
            this.loadingView.hide()
            this.tableView.reloadData()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension SearchResultViewController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollDelegate?.searchResultDidScroll(self)
    }
}

// MARK: - UITableViewDelegate

extension SearchResultViewController {
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        delegate?.searchResult(self, didClickResult: dataSource[indexPath.section][indexPath.row])
    }
}

// MARK: - UITableViewDataSource

extension SearchResultViewController {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let log = dataSource[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(LogCell.self)", for: indexPath) as! LogCell
        
        cell.flagLabel.text = log.flag
        cell.timeLabel.text = log.formatTime
        cell.logLabel.text = log.safeLog
        
        return cell
    }
}
