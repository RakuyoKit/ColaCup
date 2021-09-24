//
//  ColaCupController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

/// A controller for viewing logs
open class ColaCupController: UIViewController {
    /// Use the log manager to initialize the controller.
    ///
    /// - Parameter logManager: The log manager is required to follow the `Storable` protocol.
    public init<T: Storable>(logManager: T.Type) {
        self.viewModel = ColaCupViewModel(logManager: logManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Entrance to the filter page.
    public private(set) lazy var filterButton: UIButton = createBarButton(
        imageName: "line.horizontal.3.decrease.circle",
        selectImageName: "line.horizontal.3.decrease.circle.fill",
        action: #selector(filterButtonDidClick(_:))
    )
    
    /// The view responsible for displaying the log.
    open lazy var logsView: UITableView = {
        let tableView = UITableView(frame: .zero, style: {
            if #available(iOS 13.0, *) { return .insetGrouped }
            return .grouped
        }())
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        
        tableView.separatorColor = UIColor.theme.withAlphaComponent(0.2)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LogCell.self, forCellReuseIdentifier: "LogCell")
        
        return tableView
    }()
    
    /// The view displayed when the log data is loaded.
    open lazy var loadingView: ColaCupLoadingView = {
        let view = ColaCupLoadingView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        return view
    }()
    
    /// Used to process data.
    private let viewModel: ColaCupViewModel
    
    /// Used to provide vibration feedback.
    private lazy var feedbackGenerator = UISelectionFeedbackGenerator()
}

// MARK: - Life cycle

extension ColaCupController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = logsView.backgroundColor
        
        configNavigationBar()
        addSubviews()
        addInitialLayout()
        startProcessingData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        filterButton.isEnabled = true
        
        // Cancel the selected effect of the selected Cell.
        deselectRowIfNeeded()
    }
    
    open override var shouldAutorotate: Bool { true }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
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
            navigationItem.largeTitleDisplayMode = .automatic
            bar?.prefersLargeTitles = true
        }
    }
    
    func addSubviews() {
        view.addSubview(logsView)
        view.addSubview(loadingView)
    }
    
    func addInitialLayout() {
        func addConstraint(for aAxis: UIView.XAxis, toView bAxis: UIView.XAxis) -> NSLayoutConstraint {
            return logsView(xAxis: aAxis).constraint(equalTo: view(xAxis: bAxis))
        }
        
        // logsView
        NSLayoutConstraint.activate([
            logsView.topAnchor.constraint(equalTo: view.topAnchor),
            logsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            addConstraint(for: .leading, toView: .leading),
            addConstraint(for: .trailing, toView: .trailing),
        ])
        
        // loadingView
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leftAnchor.constraint(equalTo: view.leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: view.rightAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
            this.logsView.reloadData()
        }
    }
}

// MARK: - Action

extension ColaCupController {
    /// Execute when the button is pressed.
    ///
    /// - Parameter button: Button pressed.
    @objc open func buttonDidTouchDown(_ button: UIButton) {
        feedbackGenerator.prepare()
    }
    
    /// Close button click event.
    ///
    /// - Parameter button: `toolBar.closeButton`.
    @objc open func closeButtonDidClick(_ button: UIButton) {
        feedbackGenerator.selectionChanged()
        
        button.isEnabled = false
        dismiss(animated: true)
    }
    
    /// Filter button click event.
    ///
    /// - Parameter button: `filterButton`.
    @objc open func filterButtonDidClick(_ button: UIButton) {
        feedbackGenerator.selectionChanged()
        
        button.isEnabled = false
        
        
        
    }
}

// MARK: - TimePopoverDataDelegate

extension ColaCupController: TimePopoverDataDelegate {
    public func timePopover(_ popover: TimePopover, didChangedViewedLogDate model: TimePopoverModel) {
        viewModel.updateTimeModel(model)
        refreshLogData(executeImmediately: true)
    }
}

// MARK: - FilterPopoverDataDelegate

extension ColaCupController: FilterPopoverDataDelegate {
    
    public func filterPopover(_ popover: FilterPopover, search keyword: String) {
        
        viewModel.updateSearchKeyword(keyword)
        
        refreshLogData(executeImmediately: false)
    }
    
    public func filterPopover(_ popover: FilterPopover, clickedFlagAt index: Int, flags: [SelectedModel<Log.Flag>]) {
        
        viewModel.updateFlags(flags)
        
        refreshLogData(executeImmediately: true)
    }
    
    public func filterPopover(_ popover: FilterPopover, clickedModuleAt index: Int, modules: [SelectedModel<String>]) {
        
        viewModel.updateModules(modules)
        
        refreshLogData(executeImmediately: false)
    }
}

// MARK: - UITableViewDelegate

extension ColaCupController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0.001))
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        navigationController?.pushViewController(DetailsViewController(log: viewModel.showLogs[indexPath.row]), animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ColaCupController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.showLogs.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath) as! LogCell
        
        let log = viewModel.showLogs[indexPath.row]
        
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
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let cell = previewingContext.sourceView as? UITableViewCell,
              let indexPath = logsView.indexPath(for: cell) else {
            return nil
        }
        
        return DetailsViewController(log: viewModel.showLogs[indexPath.row])
    }
    
    public func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        navigationController?.pushViewController(viewControllerToCommit, animated: true)
    }
}

// MARK: - Tools

private extension ColaCupController {
    
    /// Refresh log data.
    /// 
    /// - Parameter executeImmediately: Whether to perform the search immediately.
    func refreshLogData(executeImmediately: Bool) {
        
        loadingView.show()
        
        viewModel.refreshLogData(executeImmediately: executeImmediately) { [weak self] in
            
            guard let this = self else { return }
            
            this.loadingView.hide()
            this.logsView.reloadData()
        }
    }
    
    /// Cancel the selected effect of the selected Cell.
    func deselectRowIfNeeded() {
        
        guard let selectedIndexPath = logsView.indexPathForSelectedRow else { return }

        guard let coordinator = transitionCoordinator else {
            logsView.deselectRow(at: selectedIndexPath, animated: true)
            return
        }

        coordinator.animate(
            alongsideTransition: { _ in
                self.logsView.deselectRow(at: selectedIndexPath, animated: true)
            },
            completion: { context in
                guard context.isCancelled else { return }
                self.logsView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: .none)
            }
        )
    }
}
