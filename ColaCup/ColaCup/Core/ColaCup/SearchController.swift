//
//  SearchController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/24.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

/// Controller for searching logs.
open class SearchController: UISearchController {
    public init() {
        let resultController = SearchResultViewController()
        self.resultController = resultController
        
        super.init(searchResultsController: resultController)
        
        self.searchBar.placeholder = "Search with keyword"
        self.resultController.scrollDelegate = self
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public let resultController: SearchResultViewController
    
    /// Is the page already displayed.
    private lazy var isShown = false
}

// MARK: - Life cycle

extension SearchController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.tintColor = .theme
        
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.getSearchTextFileld?.textColor = .normalText
        
        searchResultsUpdater = resultController
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isShown = true
    }
}

// MARK: - SearchResultViewControllerScrollDelegate

extension SearchController: SearchResultViewControllerScrollDelegate {
    open func searchResultDidScroll(_ resultController: SearchResultViewController) {
        // This method is also called when the page is first displayed.
        // If do not add this judgment, the keyboard will not pop up when you first enter the page.
        guard isShown else { return }
        
        searchBar.endEditing(true)
    }
}

// MARK: - Tools

fileprivate extension UISearchBar {
    var getSearchTextFileld: UITextField? {
        if #available(iOS 13, *) { return searchTextField }
        return value(forKey: "searchField") as? UITextField
    }
}
