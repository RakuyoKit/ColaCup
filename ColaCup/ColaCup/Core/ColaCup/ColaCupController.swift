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
    
    /// Used to process data
    public let viewModel: ColaCupViewModel
    
    /// Top view of the page. Include search box and label selection view.
    open lazy var headerView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.backgroundColor = .white
        
        return view
    }()
    
    /// Used to search logs.
    open lazy var searchBar: ColaCupSearchBar = {
        
        let searchBar = ColaCupSearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.footerView = showPopoverButton
        
        return searchBar
    }()
    
    /// Button for displaying popups.
    open lazy var showPopoverButton: UIButton = {
        
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .theme
        
        button.setImage(UIImage(systemName: "list.dash"), for: .normal)
        
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .unspecified), forImageIn: .normal)
        
        button.addTarget(self, action: #selector(showPopover(_:)), for: .touchUpInside)
        
        return button
    }()
    
    /// View to display the flag of logs.
    open lazy var flagBar: ColaCupFlagBar = {
        
        let bar = ColaCupFlagBar()
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.backgroundColor = .white
        
        bar.collectionView.register(LogFlagCell.self, forCellWithReuseIdentifier: "LogFlagCell")
        
        bar.collectionView.delegate = self
        bar.collectionView.dataSource = self
        
        return bar
    }()
    
    /// The view responsible for displaying the log.
    open lazy var logsView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = .white
        
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
}

// MARK: - Life cycle

extension ColaCupController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Solve the problem of hidden navigation bar
        navigationController?.delegate = self
        
        view.backgroundColor = .systemGroupedBackground
        
        addSubviews()
        
        addInitialLayout()
        
        startProcessingData()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showPopoverButton.isEnabled = true
    }
}

// MARK: - Config

private extension ColaCupController {
    
    func addSubviews() {
        
        view.addSubview(headerView)
        view.addSubview(logsView)
        view.addSubview(loadingView)
        
        headerView.addSubview(searchBar)
        headerView.addSubview(flagBar)
    }
    
    func addInitialLayout() {
        
        // headerView
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            headerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 10),
            headerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10)
        ])
        
        headerView.setContentHuggingPriority(.required, for: .vertical)
        
        // searchBar
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 2),
            searchBar.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 10),
            searchBar.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10)
        ])
        
        searchBar.setContentHuggingPriority(.required, for: .vertical)
        
        // categoryBar
        NSLayoutConstraint.activate([
            flagBar.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            flagBar.leftAnchor.constraint(equalTo: searchBar.leftAnchor),
            flagBar.rightAnchor.constraint(equalTo: searchBar.rightAnchor),
            flagBar.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
            flagBar.heightAnchor.constraint(equalToConstant: 37)
        ])
        
        // logsView
        NSLayoutConstraint.activate([
            logsView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            logsView.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            logsView.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            logsView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
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
            
            this.flagBar.collectionView.reloadData()
            this.logsView.reloadData()
        }
    }
}

// MARK: - Action

extension ColaCupController {
    
    /// Show pop-up view.
    ///
    /// - Parameter sender: Event trigger.
    @objc open func showPopover(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        let rect = sender.convert(sender.bounds, to: UIApplication.shared.delegate!.window!)
        
        let popover = ColaCupPopover(
            appearY: rect.maxY,
            date: viewModel.selectedDate,
            modules: viewModel.modules
        )
        
        popover.delegate = self
        
        present(popover, animated: true, completion: nil)
    }
}

// MARK: - ColaCupPopoverDelegate

extension ColaCupController: ColaCupPopoverDelegate {
    
    public func popover(_ popover: ColaCupPopover, willDisappearWithDate date: Date?, modules: [ColaCupSelectedModel]) {
        
        showPopoverButton.isEnabled = true
        
        // When changing the date, only the date is processed. Module data will be ignored.
        //
        // TODO: Use the module data selected by the user as a reference to process the selected state of the new module data
        if date != viewModel.selectedDate {
            
            loadingView.isHidden = false
            
            viewModel.selectedDate = date
            
            viewModel.processLogs { [weak self] in
                
                guard let this = self else { return }
                
                this.loadingView.isHidden = true
                
                this.flagBar.collectionView.reloadData()
                this.logsView.reloadData()
            }
            
            return
        }
        
        guard modules != viewModel.modules else { return }
        
        // Processing module data changes
        viewModel.processModuleChange { [weak self] in
            
            guard let this = self else { return }
            
            this.loadingView.isHidden = true
            
            this.flagBar.collectionView.reloadData()
            this.logsView.reloadData()
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

// MARK: - UICollectionViewDelegate

extension ColaCupController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // Move to the middle when clicked
        collectionView.scrollToItem(
            at: indexPath,
            at: [.centeredVertically, .centeredHorizontally],
            animated: true
        )
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ColaCupController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let model = viewModel.flags[indexPath.item]
        
        if let size = model.size { return size }
        
        let height: CGFloat = 37
        
        let width = (model.title as NSString).boundingRect(
            with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: height),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font : UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)],
            context: nil
        ).width
        
        let minWidth: CGFloat = 50
        
        // When greater than the minimum width,
        // a total of 112 spaces between the left and right sides are given.
        let size = CGSize(
            width: (width > minWidth) ? (width + 12) : minWidth,
            height: height
        )
        
        viewModel.flags[indexPath.item].size = size
        
        return size
    }
}

// MARK: - UICollectionViewDataSource

extension ColaCupController: UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.flags.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LogFlagCell", for: indexPath) as! LogFlagCell
        
        let model = viewModel.flags[indexPath.item]
        
        cell.isSelected = model.isSelected
        cell.titleLabel.text = model.title
        
        return cell
    }
}
