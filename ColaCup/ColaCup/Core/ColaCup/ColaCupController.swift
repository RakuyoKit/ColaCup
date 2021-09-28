//
//  ColaCupController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

public protocol ColaCupControllerDelegate: NSObjectProtocol {
    /// Needs to return the name of the file where the user was viewing the controller before entering the cup.
    ///
    /// This method will be used to implement the "Find the log of the current page" function.
    /// If you do not implement this method, then you will not be able to use this function.
    ///
    /// - Parameter controller: ColaCupController
    func nameOfFileBeforeEnterColaCup(_ controller: ColaCupController) -> String
}

/// A controller for viewing logs
open class ColaCupController: BaseLogViewController {
    /// Use the log manager to initialize the controller.
    ///
    /// - Parameter logManager: The log manager is required to follow the `Storable` protocol.
    public init<T: Storable>(logManager: T.Type) {
        self.viewModel = ColaCupViewModel(logManager: logManager)
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.getCurrentPage = { [weak self] in
            guard let this = self else { return nil }
            return this.delegate?.nameOfFileBeforeEnterColaCup(this)
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        Log.deinit(self)
        viewModel.getCurrentPage = nil
    }
    
    /// Entrance to the filter page.
    public lazy var filterButton: UIButton = createBarButton(
        imageName: "line.horizontal.3.decrease.circle",
        selectImageName: "line.horizontal.3.decrease.circle.fill",
        action: #selector(filterButtonDidClick(_:))
    )
    
    /// Controller for searching logs.
    public lazy var searchController = SearchController(searchResultsController: searchResultController)
    
    public lazy var searchResultController: SearchResultViewController = {
        let controller = SearchResultViewController()
        controller.delegate = self
        return controller
    }()
    
    /// Some delegte events.
    public weak var delegate: ColaCupControllerDelegate? = nil
    
    /// Used to process data.
    private let viewModel: ColaCupViewModel
    
    /// Used to provide vibration feedback.
    private lazy var feedbackGenerator = UISelectionFeedbackGenerator()
}

// MARK: - Life cycle

extension ColaCupController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackgroundColor
        definesPresentationContext = true
        
        configNavigationBar()
        startProcessingData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Fix the problem that the viewWillAppear method of SearchResultViewController is not executed.
        searchResultController.viewWillAppear(animated)
        
        filterButton.isEnabled = true
    }
}

// MARK: - Config

private extension ColaCupController {
    func configNavigationBar() {
        let bar = navigationController?.navigationBar
        
        bar?.tintColor = .theme
        bar?.isTranslucent = true
        bar?.backIndicatorImage = nil
        bar?.backIndicatorTransitionMaskImage = nil
        
        navigationItem.title = "ColaCup"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: filterButton)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: createBarButton(
            imageName: "xmark.circle",
            selectImageName: "xmark.circle.fill",
            action: #selector(closeButtonDidClick(_:))
        ))
        
        if #available(iOS 11.0, *) {
            bar?.prefersLargeTitles = true
            navigationItem.largeTitleDisplayMode = .automatic
            
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
        }
    }
    
    func createBarButton(imageName: String, selectImageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.isEnabled = true
        button.tintColor = .theme
        button.setImage(UIImage(name: imageName), for: .normal)
        button.setImage(UIImage(name: selectImageName), for: .selected)
        
        if #available(iOS 13.0, *) {
            let config = UIImage.SymbolConfiguration(pointSize: 40 * 0.55)
            button.setPreferredSymbolConfiguration(config, forImageIn: .normal)
            button.setPreferredSymbolConfiguration(config, forImageIn: .selected)
        }
        
        button.addTarget(self, action: #selector(buttonDidTouchDown(_:)), for: .touchDown)
        button.addTarget(self, action: action, for: .touchUpInside)
        
        return button
    }
    
    func startProcessingData() {
        loadingView.show()
        
        viewModel.processLogs { [weak self] in
            guard let this = self else { return }
            
            this.loadingView.hide()
            this.tableView.reloadData()
        }
    }
}

// MARK: - Action

extension ColaCupController {
    /// Execute when the button is pressed.
    ///
    /// - Parameter button: Button pressed.
    @objc
    open func buttonDidTouchDown(_ button: UIButton) {
        feedbackGenerator.prepare()
    }
    
    /// Close button click event.
    ///
    /// - Parameter button: `toolBar.closeButton`.
    @objc
    open func closeButtonDidClick(_ button: UIButton) {
        feedbackGenerator.selectionChanged()
        
        button.isEnabled = false
        dismiss(animated: true)
    }
    
    /// Filter button click event.
    ///
    /// - Parameter button: `filterButton`.
    @objc
    open func filterButtonDidClick(_ button: UIButton) {
        feedbackGenerator.selectionChanged()
        
        button.isEnabled = false
        
        let controller = FilterViewController(
            selectedFilter: viewModel.filterModel,
            allFlags: viewModel.allFlags,
            allModules: viewModel.allModules
        )
        controller.delegate = self
        
        let navi = UINavigationController(rootViewController: controller)
        present(navi, animated: true, completion: {})
    }
}

// MARK: - UITableViewDelegate

extension ColaCupController {
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        let log = viewModel.showLogs[indexPath.section][indexPath.row]
        navigationController?.pushViewController(DetailsViewController(log: log), animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ColaCupController {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.showLogs.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.showLogs[section].count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let log = viewModel.showLogs[indexPath.section][indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(LogCell.self)", for: indexPath) as! LogCell
        
        cell.flagLabel.text = log.flag
        cell.timeLabel.text = log.formatTime
        cell.logLabel.text = log.safeLog
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self, sourceView: cell)
        }
        
        return cell
    }
}

// MARK: - UIViewControllerPreviewingDelegate

extension ColaCupController: UIViewControllerPreviewingDelegate {
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let cell = previewingContext.sourceView as? UITableViewCell,
              let indexPath = tableView.indexPath(for: cell) else {
            return nil
        }
        
        let log = viewModel.showLogs[indexPath.section][indexPath.row]
        return DetailsViewController(log: log)
    }
    
    open func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: - SearchResultViewControllerDelegate

extension ColaCupController: SearchResultViewControllerDelegate {
    open func searchResult(_ resultController: SearchResultViewController, search keyword: String, result: @escaping ([[LogModelProtocol]]) -> Void) {
        viewModel.search(by: keyword, completion: result)
    }
    
    open func searchResult(_ resultController: SearchResultViewController, didClickResult log: LogModelProtocol) {
        navigationController?.pushViewController(DetailsViewController(log: log), animated: true)
    }
}

// MARK: - FilterViewControllerDelegate

extension ColaCupController: FilterViewControllerDelegate {
    public func filterWillDisappear(_ controller: FilterViewController) {
        filterButton.isEnabled = true
    }
    
    public func filter(_ controller: FilterViewController, didClickDoneButton button: UIButton, filter: FilterModel) {
        guard filter != viewModel.filterModel else { return }
        
        loadingView.show()
        filterButton.isSelected = viewModel.isHasFilterItem(with: filter)
        
        viewModel.filter(by: filter) { [weak self] in
            guard let this = self else { return }
            
            this.loadingView.hide()
            
            this.tableView.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: false)
            this.tableView.reloadData()
        }
    }
}
