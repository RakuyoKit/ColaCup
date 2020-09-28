//
//  DetailsViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/22.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

/// Controller that displays the details of the log
open class DetailsViewController: UIViewController {
    
    /// Initialize with log data.
    ///
    /// - Parameter log: The detailed log data to be viewed.
    public init(log: LogModelProtocol) {
        
        self.viewModel = DetailsViewModel(log: log)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Responsible for displaying a list of log details.
    open lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: {
            if #available(iOS 13.0, *) { return .insetGrouped }
            return .grouped
        }())
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        
        tableView.rowHeight =  UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        
        tableView.separatorColor = UIColor.normalText.withAlphaComponent(0.2)
        
        DetailsCellType.allCases.forEach(tableView.register(withType:))
        
        return tableView
    }()
    
    /// Used to process data.
    private let viewModel: DetailsViewModel
    
    /// Whether the tableView has been refreshed after the json has been loaded.
    private lazy var isReloaded = false
}

// MARK: - Life cycle

extension DetailsViewController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        
        addSubviews()
        addInitialLayout()
        
        let button = UIButton(type: .system)
        button.setImage(UIImage(name: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(share), for: .touchUpInside)
        
        // Share
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        
        if #available(iOS 13.0, *) {
            
            // PDF screenshot
            UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.windowScene?.screenshotService?.delegate = self
        }
    }
}

// MARK: - Config

extension DetailsViewController {
    
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

// MARK: - UIScreenshotServiceDelegate

extension DetailsViewController: UIScreenshotServiceDelegate {
    
    @available(iOS 13.0, *)
    public func screenshotService(_ screenshotService: UIScreenshotService, generatePDFRepresentationWithCompletion completionHandler: @escaping (Data?, Int, CGRect) -> Void) {
        
        guard let image = createScreenshot() else {
            completionHandler(nil, 0, .zero)
            return
        }
        
        // Convert screenshots to pdf data.
        let pdfData = NSMutableData()
        let imgView = UIImageView(image: image)
        let imageRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        UIGraphicsBeginPDFContextToData(pdfData, imageRect, nil)
        UIGraphicsBeginPDFPage()
        let context = UIGraphicsGetCurrentContext()
        imgView.layer.render(in: context!)
        UIGraphicsEndPDFContext()
        
        completionHandler(pdfData as Data, 0, .zero)
    }
}

// MARK: - Action

extension DetailsViewController {
    
    /// Share log information.
    @objc func share() {
        
        let alert = UIAlertController(title: "Share", message: "Please choose how to share log data", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Share screenshot", style: .default) { [weak self] _ in
            
            guard let this = self else { return }
            
            guard let image = this.createScreenshot() else {
                let failuerAlert = UIAlertController(title: "CreatesScreenshot failure", message: "Please try again or choose another way to share the log.", preferredStyle: .alert)
                
                failuerAlert.addAction(UIAlertAction(title: "Done", style: .cancel))
                
                this.present(failuerAlert, animated: true, completion: nil)
                return
            }
            
            let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            
            activity.excludedActivityTypes = [.assignToContact]
            
            this.present(activity, animated: true, completion: nil)
        })
        
        alert.addAction(UIAlertAction(title: "Copy logs as JSON", style: .default) { [weak self] _ in
            
            guard let this = self else { return }
            
            if let json = this.viewModel.sharedJSON {
                UIPasteboard.general.string = json

            } else {
                let failuerAlert = UIAlertController(title: "Create JSON failure", message: "Please try again or choose another way to share the log.", preferredStyle: .alert)
                
                failuerAlert.addAction(UIAlertAction(title: "Done", style: .cancel))
                
                this.present(failuerAlert, animated: true, completion: nil)
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource

extension DetailsViewController: UITableViewDataSource {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.dataSource.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource[section].items.count
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return viewModel.dataSource[section].title
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = viewModel.dataSource[indexPath.section].items[indexPath.row]
        
        let _cell = tableView.dequeueReusableCell(withIdentifier: model.type.rawValue, for: indexPath)
        
        switch model.type {
        
        case .normal:
            let cell = _cell as! DetailsNormalCell
            
            cell.textLabel?.text = model.value
            
        case .position:
            let cell = _cell as! DetailsPositionCell
            
            cell.titleLabel.text = model.title
            cell.valueLabel.text = model.value
            
            if let name = model.imageName {
                cell.iconView.image = UIImage(name: name)
            }
            
        case .function:
            let cell = _cell as! DetailsFunctionCell
            
            cell.titleLabel.text = model.title
            cell.valueLabel.text = model.value
            
            if let name = model.imageName {
                cell.iconView.image = UIImage(name: name)
            }
            
        case .json:
            let cell = _cell as! DetailsJSONCell
            
            cell.jsonView.preview(model.value) { [weak self] in
                
                guard let this = self, !this.isReloaded else { return }
                
                // The tableView needs to be refreshed to show the complete json view.
                tableView.reloadData()
                this.isReloaded = true
            }
        }
        
        return _cell
    }
}

// MARK: - Tools

private extension DetailsViewController {
    
    /// Create screenshot
    func createScreenshot() -> UIImage? {
        
        guard let tableView = createTableViewScreenshot(),
              let navi = createNaviScreenshot() else {
            
            return nil
        }
        
        let size = CGSize(
            width: max(navi.size.width, tableView.size.width),
            height: navi.size.height + tableView.size.height
        )
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        
        navi.draw(in: CGRect(origin: .zero, size: navi.size))
        
        tableView.draw(
            in: CGRect(origin: CGPoint(x: 0, y: navi.size.height), size: tableView.size)
        )
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func createTableViewScreenshot() -> UIImage? {
        
        var screenshot: UIImage? = nil
        
        UIGraphicsBeginImageContextWithOptions(tableView.contentSize, false, 0.0)
        
        // 1. Save the original offset.
        let savedContentOffset = tableView.contentOffset
        
        // 2. Set the offset and frame required for the screenshot.
        tableView.contentOffset = .zero
        tableView.frame = CGRect(x: 0, y: 0, width: tableView.contentSize.width, height: tableView.contentSize.height)
        
        // 3. Create a temporary view, and add the view to be screenshot to the temporary view.
        let tempView = UIView(frame: tableView.frame)
        tableView.removeFromSuperview()
        tempView.addSubview(tableView)
        
        // 4. Take a screenshot of the temporary view.
        tempView.layer.render(in: UIGraphicsGetCurrentContext()!)
        screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        // 5. Restore the original state of the screenshot view.
        tableView.removeFromSuperview()
        tableView.contentOffset = savedContentOffset
        
        addSubviews()
        addInitialLayout()

        UIGraphicsEndImageContext()

        return screenshot
    }
    
    func createNaviScreenshot() -> UIImage? {
        
        guard let navigationBar = navigationController?.navigationBar else { return nil }
        
        navigationItem.setHidesBackButton(true, animated: false)
        navigationItem.rightBarButtonItem?.customView?.isHidden = true
        
        UIGraphicsBeginImageContextWithOptions(navigationBar.frame.size, false, 0.0)
        
        navigationBar.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        navigationItem.setHidesBackButton(false, animated: false)
        navigationItem.rightBarButtonItem?.customView?.isHidden = false
        
        return screenshot
    }
}

fileprivate extension DetailsCellType {
    
    var cellClass: AnyClass {
        
        switch self {
        case .normal:   return DetailsNormalCell.self
        case .position: return DetailsPositionCell.self
        case .function: return DetailsFunctionCell.self
        case .json:     return DetailsJSONCell.self
        }
    }
}

fileprivate extension UITableView {
    
    func register(withType type: DetailsCellType) {
        register(type.cellClass, forCellReuseIdentifier: type.rawValue)
    }
}
