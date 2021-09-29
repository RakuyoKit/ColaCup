//
//  DetailsViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/22.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit
import LinkPresentation
import SafariServices

import RaLog
import JSONPreview

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
    
    deinit {
        if !isOriginalGeneratingDeviceOrientationNotifications {
            UIDevice.current.endGeneratingDeviceOrientationNotifications()
        }
        
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    /// Responsible for displaying a list of log details.
    open lazy var tableView: TableView = {
        let tableView = TableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        
        DetailsCellType.allCases.forEach(tableView.register(withType:))
        
        return tableView
    }()
    
    /// Display when loading the sharing popup.
    open lazy var loadingView = ColaCupLoadingView()
    
    private lazy var jsonView: JSONPreview? = nil
    
    /// Used to process data.
    private let viewModel: DetailsViewModel
    
    /// Record previous property values
    private lazy var isOriginalGeneratingDeviceOrientationNotifications = UIDevice.current.isGeneratingDeviceOrientationNotifications
    
    /// Whether the tableView has been refreshed after the json has been loaded.
    private lazy var isReloaded = false
    
    /// Height of JSON view.
    private lazy var jsonHeight: CGFloat = 0
    
    /// It is used to temporarily store the images generated during sharing to avoid repeated generation of images.
    private lazy var sharedScreenshot: UIImage? = nil
}

// MARK: - Life cycle

extension DetailsViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        
        configNavigationBar()
        
        addSubviews()
        addInitialLayout()
        
        // Listening to device rotation in preparation for recalculating cell height
        listeningDeviceRotation()
        
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
        view.addSubview(loadingView)
    }
    
    func addInitialLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        // loadingView
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func configNavigationBar() {
        if #available(iOS 11.0, *) {
            navigationItem.largeTitleDisplayMode = .never
        }
        
        let bar = navigationController?.navigationBar
        
        bar?.isTranslucent = true
        bar?.titleTextAttributes = nil
        
        // Share
        navigationItem.rightBarButtonItem = {
            if #available(iOS 14.0, *) {
                return UIBarButtonItem(systemItem: .action, menu: createShareMenu())
            }
            return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
        }()
    }
    
    func listeningDeviceRotation() {
        if !isOriginalGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleDeviceOrientationChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
}

// MARK: - Share

private extension DetailsViewController {
    @available(iOS 14.0, *)
    func createShareMenu() -> UIMenu {
        return UIMenu(
            title: "Please choose how to share log data.".locale,
            identifier: .share,
            children: [
                UIAction(title: "Text".locale, image: UIImage(systemName: "doc.text.fill.viewfinder")) { [weak self] _ in
                    self?.shareJSON()
                },
                UIAction(title: "Screenshot".locale, image: UIImage(systemName: "camera.viewfinder")) { [weak self] _ in
                    self?.shareScreenshot()
                },
            ]
        )
    }
    
    /// Share log information.
    @objc
    func share(_ shareItem: UIBarButtonItem) {
        shareItem.isEnabled = false
        
        let alert = UIAlertController(title: "Share".locale, message: "Please choose how to share log data.".locale, preferredStyle: .actionSheet)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        alert.addAction(UIAlertAction(title: "Text".locale, style: .default) { [weak self] _ in
            self?.shareJSON()
        })
        
        alert.addAction(UIAlertAction(title: "Screenshot".locale, style: .default) { [weak self] _ in
            self?.shareScreenshot()
        })
        
        alert.addAction(UIAlertAction(title: "Cancel".locale, style: .cancel) { _ in
            shareItem.isEnabled = true
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func shareJSON() {
        loadingView.show()
        showActivity(with: viewModel.sharedJSON)
    }
    
    func shareScreenshot() {
        loadingView.show()
        
        if let image = createScreenshot() {
            // Temporary storage of pictures to avoid repeated creation of pictures
            // in the `UIActivityItemSource` protocol.
            sharedScreenshot = image
            
            showActivity(with: image)
            return
        }
        
        navigationItem.rightBarButtonItem?.isEnabled = true
        loadingView.hide()
        
        let alert = UIAlertController(title: "Create Screenshot failure".locale, message: "Please try again or choose another way to share the log.".locale, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Done".locale, style: .cancel))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showActivity(with item: Any) {
        let items: [Any] = {
            if let image = item as? UIImage { return [image, self] }
            if let json  = item as? String  { return [json] }
            return [item, self]
        }()
        
        let activity = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        activity.excludedActivityTypes = [.assignToContact]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            activity.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        }
        
        let presentBlock: () -> Void = { [weak self] in
            self?.present(activity, animated: true) {
                guard let this = self else { return }
                
                this.navigationItem.rightBarButtonItem?.isEnabled = true
                this.loadingView.hide()
            }
        }
        
        if #available(iOS 14.0, *) {
            // Stuttering occurs when present.
            // So delay for a certain period of time
            // to avoid the lag from affecting the recovery animation of UIMenu.
            DispatchQueue.main.asyncAfter(
                deadline: .now() + .milliseconds(300),
                execute: presentBlock
            )
            
        } else {
            presentBlock()
        }
    }
}

// MARK: - Screenshot

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
        
        UIGraphicsBeginImageContextWithOptions(navigationBar.frame.size, false, 0.0)
        
        navigationBar.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        navigationItem.setHidesBackButton(false, animated: false)
        
        return screenshot
    }
}

// MARK: - Action

private extension DetailsViewController {
    @objc
    func handleDeviceOrientationChange(_ notification: NSNotification) {
        guard let jsonTextView = jsonView?.jsonTextView else { return }
        
        let size = jsonTextView.sizeThatFits(
            CGSize(width: jsonTextView.frame.width, height: CGFloat.greatestFiniteMagnitude)
        )
        
        jsonHeight = size.height + 1
        tableView.reloadData()
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

// MARK: - UIActivityItemSource

extension DetailsViewController: UIActivityItemSource {
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    public func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        return nil
    }

    @available(iOS 13.0, *)
    public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        guard let image = sharedScreenshot else { return nil }
        
        let metadata = LPLinkMetadata()
        
        metadata.title = "log_detail_screenshot"
        metadata.imageProvider = NSItemProvider(object: image)
        
        return metadata
    }
}

// MARK: - UITableViewDelegate

extension DetailsViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = viewModel.dataSource[indexPath.section].items[indexPath.row]
        
        if case .json = model.type { return jsonHeight }
        return UITableView.automaticDimension
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
        return viewModel.dataSource[section].title?.locale
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
            
            cell.titleLabel.text = model.title?.locale
            cell.valueLabel.text = model.value
            
            if let name = model.imageName {
                cell.iconView.image = UIImage(name: name)
            }
            
        case .function:
            let cell = _cell as! DetailsFunctionCell
            
            cell.titleLabel.text = model.title?.locale
            cell.valueLabel.text = model.value
            
            if let name = model.imageName {
                cell.iconView.image = UIImage(name: name)
            }
            
        case .json:
            let cell = _cell as! DetailsJSONCell
            cell.jsonView.delegate = self
            jsonView = cell.jsonView
            
            guard !isReloaded else { break }
            
            cell.jsonView.preview(model.value) { [weak self] in
                guard let this = self else { return }
                
                func reload() {
                    // Update the height of the JSON view.
                    this.jsonHeight = cell.jsonView.jsonTextView.contentSize.height
                    
                    tableView.reloadRows(at: [indexPath], with: .none)
                    this.isReloaded = true
                }
                
                // In iOS 13 and above, the exact height can be read immediately.
                // On the contrary, it needs to be refreshed twice in the main thread to read the correct height.
                if #available(iOS 13.0, *) {
                    if !this.isReloaded { reload() }
                } else {
                    DispatchQueue.main.async(execute: reload)
                }
            }
        }
        
        return _cell
    }
}

// MARK: - JSONPreviewDelegate

extension DetailsViewController: JSONPreviewDelegate {
    public func jsonPreview(view: JSONPreview, didClickURL url: URL, on textView: UITextView) -> Bool {
        let safari = SFSafariViewController(url: url)
        safari.modalPresentationStyle = .overFullScreen
        present(safari, animated: true, completion: nil)
        
        return false
    }
}

// MARK: - Tools

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
