//
//  FilterViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

public protocol FilterViewControllerDelegate: NSObjectProtocol {
    /// Called when the page is about to close.
    ///
    /// - Parameter controller: Filter controllers that are turned off.
    func filterWillDisappear(_ controller: FilterViewController)
    
    /// Callback when the done button is clicked.
    ///
    /// - Parameters:
    ///   - controller: Current filter controller.
    ///   - button: The button that was clicked.
    ///   - filter: User-selected filters.
    func filter(_ controller: FilterViewController, didClickDoneButton button: UIButton, filter: FilterModel)
}

/// The controller used to select the filtering conditions.
open class FilterViewController: UIViewController {
    /// Initializes with the currently selected filter condition.
    ///
    /// - Parameters:
    ///   - filter: currently selected filter condition.
    ///   - flags: The set of all logs currently displayed, with the flags they belong to.
    ///   - modules: The set of all logs currently displayed, with the module they belong to.
    public init(
        selectedFilter filter: FilterModel,
        allFlags flags: [Flag],
        allModules modules: [String]
    ) {
        self.viewModel = FilterViewModel(selectedFilter: filter, allFlags: flags, allModules: modules)
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
        
        collectionView.contentInset = UIEdgeInsets(top: Constants.sectionSpacing, left: 0, bottom: 0, right: 0)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
    }()
    
    /// done button at the bottom.
    open lazy var doneView: FilterDoneButtonView = {
        let doneView = FilterDoneButtonView(frame: .zero)
        
        doneView.doneButton.addTarget(self, action: #selector(doneButtonDidTouchDown(_:)), for: .touchDown)
        doneView.doneButton.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
        
        return doneView
    }()
    
    public weak var delegate: FilterViewControllerDelegate? = nil
    
    /// Used to process data.
    private let viewModel: FilterViewModel
    
    /// Used to provide vibration feedback.
    private lazy var feedbackGenerator = UISelectionFeedbackGenerator()
}

// MARK: - Life cycle

extension FilterViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        configNavigationBar()
        
        addSubviews()
        addInitialLayout()
        
        collectionView.register(FilterHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        
        collectionView.register(FilterCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.filterWillDisappear(self)
    }
}

// MARK: - Constants

private extension FilterViewController {
    enum Constants {
        static let sectionSpacing: CGFloat = 15
        static let cellSpacing: CGFloat = 10
        
        static let sectionInsert = UIEdgeInsets(
            top: sectionSpacing,
            left: sectionSpacing,
            bottom: sectionSpacing * 2,
            right: sectionSpacing
        )
        
        static let totalSpacing = Constants.sectionInsert.left + Constants.sectionInsert.right + Constants.cellSpacing
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
    /// Cancel button click events
    @objc
    open func cancelButtonDidClick(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Reset button click events
    @objc
    open func resetButtonDidClick(_ sender: UIBarButtonItem) {
        viewModel.reset()
        collectionView.reloadData()
    }
    
    /// Execute when the button is pressed.
    ///
    /// - Parameter button: Button pressed.
    @objc
    open func doneButtonDidTouchDown(_ button: UIButton) {
        feedbackGenerator.prepare()
    }
    
    /// Done button click events
    @objc
    open func doneButtonDidClick(_ sender: UIButton) {
        feedbackGenerator.selectionChanged()
        delegate?.filter(self, didClickDoneButton: sender, filter: viewModel.selectedFilter)
        dismiss(animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension FilterViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! FilterHeaderView
        
        headerView.label.text = viewModel.dataSource[indexPath.section].title
        
        return headerView
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return Constants.sectionInsert
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.cellSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.cellSpacing
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - Constants.totalSpacing) * 0.5
        return CGSize(width: width, height: 55)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 44)
    }
}

// MARK: - UICollectionViewDataSource

extension FilterViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.dataSource[section].values.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FilterCell
        
        
        
        return cell
    }
}
