//
//  FilterPopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/16.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// A pop-up window for displaying filter options.
public class FilterPopover: BasePopover {
    
    /// Initialization method.
    /// 
    /// - Parameter dataSource: The data source model of the content of the pop-up.
    public init(position: CGPoint, dataSource: PopoverModel) {
        viewModel = FilterPopoverViewModel(dataSource: dataSource)
        
        super.init(position: position)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// View Model.
    private let viewModel: FilterPopoverViewModel
    
    /// Used to search logs.
    open lazy var searchBar: ColaCupSearchBar = {
        
        let searchBar = ColaCupSearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
//        searchBar.searchDelegate = self
//        searchBar.textFieldDelegate = self
        
        return searchBar
    }()
    
    /// View to display the flag of logs.
    open lazy var flagBar: ColaCupFlagBar = {
        
        let bar = ColaCupFlagBar()
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .white
        
//        bar.delegate = self
        
        return bar
    }()
}

// MARK: - Life cycle

extension FilterPopover {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addGesture()
    }
}

// MARK: - Config

private extension FilterPopover {
    
    func addGesture() {
        
        let ges = UITapGestureRecognizer(target: searchBar, action: #selector(resignFirstResponder))
        
        ges.cancelsTouchesInView = false
        
        view.addGestureRecognizer(ges)
    }
    
    func addSubviews() {
        
        stackView.addArrangedSubview(searchBar)
        stackView.addArrangedSubview(flagBar)
    }
    
    func addInitialLayout() {
        
        [searchBar, flagBar].forEach {
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }
}
