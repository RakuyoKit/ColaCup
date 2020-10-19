//
//  ColaCupSearchBar.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/22.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Search bar in `ColaCupController`
open class ColaCupSearchBar: UIView {
    
    public init() {
        super.init(frame: .zero)
        config()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    open weak var searchDelegate: UISearchBarDelegate? = nil {
        didSet { searchBar.delegate = searchDelegate }
    }
    
    weak open var textFieldDelegate: UITextFieldDelegate? = nil {
        didSet { searchBar.getSearchTextFileld?.delegate = textFieldDelegate }
    }
    
    /// The parent view of all the views below. Responsible for layout constraints.
    open lazy var stackView: UIStackView = {
        
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        
        return stackView
    }()
    
    /// Custom view displayed on the right side of the search bar.
    open lazy var footerView: UIView? = nil {
        didSet {
            guard let view = footerView else { return }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.insertArrangedSubview(view, at: stackView.arrangedSubviews.count)
        }
    }
    
    /// Search bar.
    open lazy var searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.tintColor = .theme
        searchBar.backgroundImage = UIImage()
        
        searchBar.returnKeyType = .done
        searchBar.placeholder = "Search with keyword"
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.getSearchTextFileld?.textColor = .normalText
        
        return searchBar
    }()
}

extension ColaCupSearchBar {
    
    open var text: String? {
        set { searchBar.getSearchTextFileld?.text = newValue }
        get { searchBar.getSearchTextFileld?.text }
    }
    
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        searchBar.resignFirstResponder()
        return super.resignFirstResponder()
    }
}

// MARK: - Config

private extension ColaCupSearchBar {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(stackView)
        stackView.addArrangedSubview(searchBar)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

// MARK: - Tools

fileprivate extension UISearchBar {
    
    var getSearchTextFileld: UITextField? {
        
        if #available(iOS 13, *) {
            return searchTextField
        } else {
            return value(forKey: "searchField") as? UITextField
        }
    }
}
