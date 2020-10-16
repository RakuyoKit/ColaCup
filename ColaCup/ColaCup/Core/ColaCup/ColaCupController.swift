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
    
    
    
    /// Used to search logs.
    open lazy var searchBar: ColaCupSearchBar = {
        
        let searchBar = ColaCupSearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        searchBar.searchDelegate = self
        searchBar.textFieldDelegate = self
        
        return searchBar
    }()
    
    /// View to display the flag of logs.
    open lazy var flagBar: ColaCupFlagBar = {
        
        let bar = ColaCupFlagBar()
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .white
        
        bar.delegate = self
        
        return bar
    }()
    
    
    
    /// Top toolbar.
    open lazy var toolBar: ColaCupToolBar = {
        
        let bar = ColaCupToolBar()
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        // closeButton
        bar.closeButton.addTarget(self, action: #selector(closeButtonDidClick(_:)), for: .touchUpInside)
        
        // sortButton
        bar.sortButton.tag = 1
        bar.sortButton.addTarget(self, action: #selector(sortButtonDidClick(_:)), for: .touchUpInside)
        
        // filterButton
        bar.filterButton.addTarget(self, action: #selector(filterButtonDidClick(_:)), for: .touchUpInside)
        
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
    
    /// Whether the pop-up window is being displayed
    private lazy var isShowingPopover = false
}

// MARK: - Life cycle

extension ColaCupController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = logsView.backgroundColor
        
        // Solve the problem of hidden navigation bar
        navigationController?.delegate = self
        navigationController?.navigationBar.tintColor = .theme
        
        addGesture()
        addSubviews()
        addInitialLayout()
        startProcessingData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    func addGesture() {
        
        let ges = UITapGestureRecognizer(target: searchBar, action: #selector(resignFirstResponder))
        
        ges.cancelsTouchesInView = false
        
        view.addGestureRecognizer(ges)
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
            
            this.flagBar.setFlags(this.viewModel.flags)
            this.logsView.reloadData()
        }
    }
}

// MARK: - Action

extension ColaCupController {
    
    /// Close button click event.
    ///
    /// - Parameter button: `toolBar.closeButton`.
    @objc open func closeButtonDidClick(_ button: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    /// Filter button click event.
    ///
    /// - Parameter button: `toolBar.filterButton`.
    @objc open func filterButtonDidClick(_ button: UIButton) {
        
        button.isEnabled = false
        
        let rect = button.convert(button.bounds, to: UIApplication.shared.delegate!.window!)
        
        let popover = ColaCupPopover(
            appearY: rect.maxY,
            date: viewModel.selectedDate,
            modules: viewModel.modules
        )
        
        popover.delegate = self
        
        present(popover, animated: true) { self.isShowingPopover = true }
    }
    
    /// Sort button click event.
    ///
    /// - Parameter button: `toolBar.sortButton`.
    @objc open func sortButtonDidClick(_ button: UIButton) {
        
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
    
    public func popover(_ popover: ColaCupPopover, willDisappearWithDate date: Date?, modules: [ColaCupSelectedModel]) {
        
        isShowingPopover = false
        toolBar.filterButton.isEnabled = true
        
        // When changing the date, only the date is processed. Module data will be ignored.
        //
        // TODO: Use the module data selected by the user as a reference to process the selected state of the new module data
        if date != viewModel.selectedDate {
            
            loadingView.isHidden = false
            
            viewModel.selectedDate = date
            
            viewModel.processLogs { [weak self] in
                
                guard let this = self else { return }
                
                this.loadingView.isHidden = true
                
                this.reloadFlagData()
                this.logsView.reloadData()
            }
            
            return
        }
        
        guard modules != viewModel.modules else { return }
        
        loadingView.isHidden = false
        
        viewModel.modules = modules
        
        // Processing module data changes
        viewModel.processModuleChange { [weak self] in
            
            guard let this = self else { return }
            
            this.loadingView.isHidden = true
            
            this.searchBar.text = ""
            this.reloadFlagData()
            this.logsView.reloadData()
        }
    }
}

// MARK: - ColaCupFlagBarDelegate

extension ColaCupController: ColaCupFlagBarDelegate {
    
    public func flagBar(_ flagBar: ColaCupFlagBar, flagButtonDidClick button: LogFlagButton) {
        
        loadingView.isHidden = false
        
        viewModel.clickFlag(at: button.tag, isSelectButton: button.isSelected) { [weak self] in
            
            guard let this = self else { return }
            
            this.loadingView.isHidden = true
            this.logsView.reloadData()
            
            if $0.contains(0) {
                flagBar.scrollToLeft()
            }
            
            $0.forEach { this.flagBar.selectFlag(at: $0) }
            $1.forEach { this.flagBar.deselectFlag(at: $0) }
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension ColaCupController: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let isHide = viewController is ColaCupController
        navigationController.setNavigationBarHidden(isHide, animated: animated)
    }
}

// MARK: - UISearchBarDelegate

extension ColaCupController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        viewModel.search(with: searchText, executeImmediately: false) { [weak self] in
            self?.logsView.reloadData()
        }
    }
}

// MARK: - UITextFieldDelegate

extension ColaCupController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        viewModel.search(with: textField.text, executeImmediately: true) { [weak self] in
            self?.logsView.reloadData()
        }
        
        return false
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
    
    func reloadFlagData() {
        flagBar.scrollToLeft()
        flagBar.reloadData(flags: viewModel.flags)
    }
}
