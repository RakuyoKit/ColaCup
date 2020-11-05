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
    
    /// Used to process data.
    private let viewModel: ColaCupViewModel
    
    /// Top toolbar.
    open lazy var toolBar: ColaCupToolBar = {
        
        let bar = ColaCupToolBar()
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        // closeButton
        bar.closeButton.addTarget(self, action: #selector(closeButtonDidClick(_:)), for: .touchUpInside)
        
        // sortButton
        bar.sortButton.tag = 1
        bar.sortButton.addTarget(self, action: #selector(sortButtonDidClick(_:)), for: .touchUpInside)
        
        // timeButton
        bar.timeButton.addTarget(self, action: #selector(timeButtonDidClick(_:)), for: .touchUpInside)
        
        // filterButton
        bar.filterButton.addTarget(self, action: #selector(filterButtonDidClick(_:)), for: .touchUpInside)
        
        [bar.closeButton, bar.sortButton, bar.timeButton, bar.filterButton].forEach {
            $0.addTarget(self, action: #selector(buttonDidTouchDown(_:)), for: .touchDown)
        }
        
        return bar
    }()
    
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
        view.backgroundColor = .clear
        view.isHidden = true
        
        view.activityIndicator.color = .theme
        
        return view
    }()
    
    /// Whether the pop-up window is being displayed.
    private lazy var isShowingPopover = false
    
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
        
        toolBar.timeButton.isEnabled = true
        toolBar.filterButton.isEnabled = true
        
        // Cancel the selected effect of the selected Cell.
        deselectRowIfNeeded()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        if isShowingPopover {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    open override var shouldAutorotate: Bool { true }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
}

// MARK: - Config

private extension ColaCupController {
    
    func configNavigationBar() {
        
        // Solve the problem of hidden navigation bar
        navigationController?.delegate = self
        
        navigationController?.navigationBar.tintColor = .theme
        navigationController?.navigationBar.backIndicatorImage = nil
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = nil
    }
    
    func addSubviews() {
        
        view.addSubview(toolBar)
        view.addSubview(logsView)
        view.addSubview(loadingView)
    }
    
    func addInitialLayout() {
        
        // toolBar
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                toolBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
                toolBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 20),
                toolBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20)
            ])
            
        } else {
            NSLayoutConstraint.activate([
                toolBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
                toolBar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
                toolBar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
            ])
        }
        
        toolBar.setContentHuggingPriority(.required, for: .vertical)
        
        // logsView
        var logsViewConstraints = [
            logsView.topAnchor.constraint(equalTo: toolBar.bottomAnchor, constant: 15),
            logsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        if #available(iOS 11.0, *) {
            logsViewConstraints.append(logsView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor))
            logsViewConstraints.append(logsView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor))
        } else {
            logsViewConstraints.append(logsView.leftAnchor.constraint(equalTo: view.leftAnchor))
            logsViewConstraints.append(logsView.rightAnchor.constraint(equalTo: view.rightAnchor))
        }
        
        NSLayoutConstraint.activate(logsViewConstraints)
        
        // loadingView
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 90),
            loadingView.heightAnchor.constraint(equalTo: loadingView.widthAnchor),
        ])
    }
    
    func startProcessingData() {
        
        loadingView.isHidden = false
        
        viewModel.processLogs { [weak self] in
            
            guard let this = self else { return }
            
            this.loadingView.isHidden = true
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
        dismiss(animated: true, completion: nil)
    }
    
    /// Time button click event.
    ///
    /// - Parameter button: `toolBar.timeButton`.
    @objc open func timeButtonDidClick(_ button: UIButton) {
        
        feedbackGenerator.selectionChanged()
        
        button.isEnabled = false
        
        let rect = button.convert(button.bounds, to: UIApplication.shared.delegate!.window!)
        
        let popover = TimePopover(
            position: CGPoint(x: rect.midX, y: rect.maxY),
            dataSource: viewModel.timeModel
        )
        
        popover.delegate = self
        popover.dataDelegate = self
        
        present(popover, animated: true) { self.isShowingPopover = true }
    }
    
    /// Filter button click event.
    ///
    /// - Parameter button: `toolBar.filterButton`.
    @objc open func filterButtonDidClick(_ button: UIButton) {
        
        feedbackGenerator.selectionChanged()
        
        button.isEnabled = false
        
        let rect = button.convert(button.bounds, to: UIApplication.shared.delegate!.window!)
        
        let popover = FilterPopover(
            position: CGPoint(x: rect.midX, y: rect.maxY),
            dataSource: viewModel.filterModel
        )
        
        popover.delegate = self
        popover.dataDelegate = self
        
        present(popover, animated: true) { self.isShowingPopover = true }
    }
    
    /// Sort button click event.
    ///
    /// - Parameter button: `toolBar.sortButton`.
    @objc open func sortButtonDidClick(_ button: UIButton) {
        
        feedbackGenerator.selectionChanged()
        
        if button.tag == 1 {
            button.tag = 2
            button.setImage(UIImage(name: "arrow.counterclockwise.circle"), for: .normal)
            
        } else {
            button.tag = 1
            button.setImage(UIImage(name: "arrow.clockwise.circle"), for: .normal)
        }
        
        viewModel.reverseDataSource()
        logsView.reloadData()
    }
}

// MARK: - ColaCupPopoverDelegate

extension ColaCupController: ColaCupPopoverDelegate {
    
    public func popoverWillDisappear<Popover>(_ popover: Popover) where Popover : BasePopover {
        
        isShowingPopover = false
        
        toolBar.timeButton.isEnabled = true
        toolBar.filterButton.isEnabled = true
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

// MARK: - UINavigationControllerDelegate

extension ColaCupController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let isHide = viewController is ColaCupController
        navigationController.setNavigationBarHidden(isHide, animated: animated)
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
        
        loadingView.isHidden = false
        
        viewModel.refreshLogData(executeImmediately: executeImmediately) { [weak self] in
            
            guard let this = self else { return }
            
            this.loadingView.isHidden = true
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
