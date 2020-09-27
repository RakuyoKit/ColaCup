//
//  ColaCupPopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

public protocol ColaCupPopoverDelegate: class {
    
    /// Execute when the pop-up window is about to disappear,
    /// and call back the data to the caller.
    ///
    /// All the data below will not detect whether the comparison has changed during initialization.
    ///
    /// You need to judge by yourself whether the data has changed.
    ///
    /// - Parameters:
    ///   - popover: The popup itself.
    ///   - date: The date currently selected by the user.
    ///   - modules: Module array.
    func popover(
        _ popover: ColaCupPopover,
        willDisappearWithDate date: Date?,
        modules: [ColaCupSelectedModel]
    )
}

/// Pop-up view, including date selection and module filtering.
open class ColaCupPopover: UIViewController {
    
    /// Initialize the pop-up window controller with the date and module of the currently viewed log.
    ///
    /// - Parameters:
    ///   - appearY: Y coordinate of the point.
    ///   - date: The date of the currently viewed log.
    ///   - modules: The modules to which the currently viewed log belongs.
    init(appearY: CGFloat, date: Date?, modules: [ColaCupSelectedModel]) {
        self.appearY = appearY
        self.date = date
        self.modules = modules
        
        super.init(nibName: nil, bundle: nil)
        
        configAnimation()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The date of the currently viewed log.
    private var date: Date?
    
    /// The modules to which the currently viewed log belongs.
    private var modules: [ColaCupSelectedModel]
    
    /// Y coordinate of the point.
    private let appearY: CGFloat
    
    /// The proxy used for callback data.
    open weak var delegate: ColaCupPopoverDelegate? = nil
    
    /// TableView showing the list of modules
    open lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: .plain)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.bounces = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(PopoverDatePickerCell.self, forCellReuseIdentifier: "PopoverDatePickerCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        return tableView
    }()
}

// MARK: - Life cycle

extension ColaCupPopover {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        addSubviews()
        
        addInitialLayout()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Call back the caller to facilitate the caller to refresh the page.
        delegate?.popover(self, willDisappearWithDate: date, modules: modules)
    }
}

// MARK: - Config

private extension ColaCupPopover {
    
    func configAnimation() {
        
        modalPresentationStyle = .custom
        
        // Set the animation agent to itself,
        // so that regardless of any external controller displaying the controller,
        // the identity of the animation will be guaranteed
        transitioningDelegate = self
    }
    
    func addSubviews() {
        
        view.addSubview(tableView)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

// MARK: - Action

extension ColaCupPopover {
    
    @objc open func handleDatePicker(_ datePicker: UIDatePicker) {
        date = datePicker.date
    }
}

// MARK: - UITableViewDelegate

extension ColaCupPopover: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return section == 0 ? 0.001 : 12
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: section == 0 ? 0.001 : 12))
        
        view.backgroundColor = .systemGroupedBackground
        
        return view
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        modules[indexPath.row].isSelected = !modules[indexPath.row].isSelected
        
        tableView.cellForRow(at: indexPath)?.accessoryType = modules[indexPath.row].isSelected ? .checkmark : .none
    }
}

// MARK: - UITableViewDataSource

extension ColaCupPopover: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : modules.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PopoverDatePickerCell", for: indexPath) as! PopoverDatePickerCell
            
            cell.datePicker.date = date ?? Date()
            cell.datePicker.addTarget(self, action: #selector(handleDatePicker(_:)), for: .valueChanged)
            
            return cell
        }
        
        let model = modules[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.separatorInset = .zero
        cell.textLabel?.text = model.title
        cell.tintColor = .theme
        cell.accessoryType = model.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ColaCupPopover: UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return PopoverPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        let height = 44 * CGFloat(modules.count + 1) + 12
        
        return PopoverAppearAnimation(y: appearY, height: height)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return PopoverDisappearAnimation()
    }
}
