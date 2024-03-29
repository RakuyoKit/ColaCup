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
    public override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        
        configSearchBar()
        
        if let resultController = searchResultsController as? SearchResultViewController {
            resultController.scrollDelegate = self
            searchResultsUpdater = resultController
        }
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Is the page already displayed.
    private lazy var isShown = false
}

// MARK: - Life cycle

extension SearchController {
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        isShown = true
    }
}

// MARK: - Config

private extension SearchController {
    func configSearchBar() {
        obscuresBackgroundDuringPresentation = true
        
        searchBar.tintColor = .theme
        
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.placeholder = "Search with keyword".locale
        searchBar.getSearchTextFileld?.textColor = .normalText
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
