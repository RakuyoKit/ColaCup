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
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        
        return stackView
    }()
    
    /// List for displaying filter criteria.
    open lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            collectionView.backgroundColor = .systemGroupedBackground
        } else {
            collectionView.backgroundColor = .groupTableViewBackground
        }
        
        collectionView.showsHorizontalScrollIndicator = false
        
        return collectionView
    }()
    
    /// done button at the bottom.
    open lazy var doneView: FilterDoneButtonView = {
        let doneView = FilterDoneButtonView(frame: .zero)
        
        return doneView
    }()
    
    /// Used to process data.
    private let viewModel: FilterViewModel
}

// MARK: - Life cycle

extension FilterViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationBar()
        
        addSubviews()
        addInitialLayout()
    }
}

// MARK: - Config

private extension FilterViewController {
    func configNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        navigationItem.title = "Filter Log"
        navigationController?.navigationBar.tintColor = .theme
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidClick(_:)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reset", style: .plain, target: self, action: #selector(resetButtonDidClick(_:)))
    }
    
    func addSubviews() {
        view.addSubview(stackView)
        
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(doneView)
    }
    
    func addInitialLayout() {
        // stackView
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        doneView.setContentHuggingPriority(.required, for: .vertical)
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
