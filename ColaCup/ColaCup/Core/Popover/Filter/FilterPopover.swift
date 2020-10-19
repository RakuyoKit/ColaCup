//
//  FilterPopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/16.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import RaLog

/// Delegate for callback data.
public protocol FilterPopoverDataDelegate: class {
    
    /// Execute when searching.
    ///
    /// - Parameters:
    ///   - popover: `FilterPopover`.
    ///   - keyword: The keyword that the user wants to search.
    func filterPopover(_ popover: FilterPopover, search keyword: String)
    
    /// Execute when the flag button is clicked.
    ///
    /// - Parameters:
    ///   - popover: `FilterPopover`.
    ///   - index: The position of the flag button that the user clicked. Start from 0.
    func filterPopover(_ popover: FilterPopover, clickedFlagAt index: Int, flags: [ColaCupSelectedModel<Log.Flag>])
}

/// A pop-up window for displaying filter options.
public class FilterPopover: BasePopover {
    
    /// Initialization method.
    /// 
    /// - Parameter dataSource: The data source model of the content of the pop-up.
    public init(position: CGPoint, dataSource: FilterPopoverModel) {
        viewModel = FilterPopoverViewModel(dataSource: dataSource)
        
        super.init(position: position)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// View Model.
    private let viewModel: FilterPopoverViewModel
    
    /// delegate for callback data
    public weak var dataDelegate: FilterPopoverDataDelegate? = nil
    
    /// Used to search logs.
    open lazy var searchBar: ColaCupSearchBar = {
        
        let searchBar = ColaCupSearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.text = viewModel.searchKeyword
        
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
    
    /// TableView showing the list of modules.
    open lazy var moduleView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.separatorColor = UIColor.theme.withAlphaComponent(0.2)
        tableView.bounces = viewModel.isTableViewBounces
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        
        return tableView
    }()
    
    public override var height: CGFloat {
        
        return BasePopover.Constant.topBottomSpacing * 2
             + BasePopover.Constant.spacing * 2
             + Constant.itemHeight * (2 + viewModel.showModuleCount)
             + 2
    }
}

// MARK: - Life cycle

extension FilterPopover {
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        addGesture()
        addSubviews()
        addInitialLayout()
        
        flagBar.setFlags(viewModel.flags)
    }
}

// MARK: - Config

private extension FilterPopover {
    
    enum Constant {
        
        /// The height of each item
        static let itemHeight: CGFloat = 44
    }
}

private extension FilterPopover {
    
    func addGesture() {
        
        let ges = UITapGestureRecognizer(target: searchBar, action: #selector(resignFirstResponder))
        
        ges.cancelsTouchesInView = false
        
        view.addGestureRecognizer(ges)
    }
    
    func addSubviews() {
        
        stackView.addArrangedSubview(searchBar)
        stackView.addArrangedSubview(flagBar)
        stackView.addArrangedSubview(moduleView)
    }
    
    func addInitialLayout() {
        
        [searchBar, flagBar].forEach {
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        
        let height = viewModel.showModuleCount * Constant.itemHeight + 2
        
        NSLayoutConstraint.activate([
            moduleView.heightAnchor.constraint(equalToConstant: height),
            moduleView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])
    }
}

// MARK: - ColaCupFlagBarDelegate

extension FilterPopover: ColaCupFlagBarDelegate {
    
    public func flagBar(_ flagBar: ColaCupFlagBar, flagButtonDidClick button: LogFlagButton) {
        
        let index = button.tag
        
        viewModel.clickFlag(at: index) { [weak self] in
            
            guard let this = self else { return }
            
            if $0.contains(0) {
                flagBar.scrollToLeft()
            }
            
            $0.forEach { this.flagBar.selectFlag(at: $0) }
            $1.forEach { this.flagBar.deselectFlag(at: $0) }
            
            this.dataDelegate?.filterPopover(this, clickedFlagAt: index, flags: this.viewModel.flags)
        }
    }
}

// MARK: - UISearchBarDelegate

extension FilterPopover: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        guard searchText != viewModel.searchKeyword else { return }
        
        viewModel.searchKeyword = searchText
        
        dataDelegate?.filterPopover(self, search: searchText)
    }
}

// MARK: - UITextFieldDelegate

extension FilterPopover: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return false
    }
}

// MARK: - UITableViewDelegate

extension FilterPopover: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0.001))
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        return UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0.001))
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let getCell: (IndexPath) -> UITableViewCell? = {
            return tableView.cellForRow(at: $0)
        }
        
        let getAllCell: () -> UITableViewCell? = {
            return getCell(IndexPath(row: 0, section: 0))
        }
        
        viewModel.selectModule(at: indexPath.row, animations: {
            
            switch $0 {
            
            case .reload:
                tableView.reloadData()
                
            case .checkAll:
                getAllCell()?.accessoryType = .checkmark
                
            case .uncheckAll:
                getAllCell()?.accessoryType = .none
                
            case .checkClicked:
                getCell(indexPath)?.accessoryType = .checkmark
                
            case .uncheckClicked:
                getCell(indexPath)?.accessoryType = .none
            }
        })
    }
}

// MARK: - UITableViewDataSource

extension FilterPopover: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.modules.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = viewModel.modules[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        
        cell.separatorInset = .zero
        cell.textLabel?.text = model.value
        cell.tintColor = .theme
        cell.accessoryType = model.isSelected ? .checkmark : .none
        cell.selectionStyle = .none
        
        return cell
    }
}
