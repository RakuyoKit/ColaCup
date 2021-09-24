//
//  SearchController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/24.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

/// Controller for searching logs.
class SearchController: UISearchController {
    init() {
        let resultController = SearchResultViewController()
        self.resultController = resultController
        
        super.init(searchResultsController: resultController)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let resultController: SearchResultViewController
}

extension SearchController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.tintColor = .theme
        
        searchBar.returnKeyType = .search
        searchBar.placeholder = "Search with keyword"
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.getSearchTextFileld?.textColor = .normalText
        
        searchResultsUpdater = resultController
    }
}

// MARK: - Tools

fileprivate extension UISearchBar {
    var getSearchTextFileld: UITextField? {
        if #available(iOS 13, *) { return searchTextField }
        return value(forKey: "searchField") as? UITextField
    }
}
