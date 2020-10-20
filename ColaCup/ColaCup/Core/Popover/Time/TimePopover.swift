//
//  TimePopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Delegate for callback data.
@available(iOS 14.0, *)
public protocol TimePopoverDataDelegate: class {
    
    /// The callback executed after the user clicks the OK button on the pop-up.
    ///
    /// - Parameters:
    ///   - popover: `TimePopover`.
    ///   - model: Modified model.
    func timePopover(_ popover: TimePopover, didChangedViewedLogDate model: TimePopoverModel)
}

/// A pop-up window for displaying time options.
@available(iOS 14.0, *)
public class TimePopover: BasePopover {
    
    /// Initialization method.
    ///
    /// - Parameter dataSource: The data source model of the content of the pop-up.
    public init(position: CGPoint, dataSource: TimePopoverModel) {
        self.dataSource = dataSource
        super.init(position: position)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Data source.
    private var dataSource: TimePopoverModel
    
    /// Whether the tag data has changed.
    private lazy var isDataChanged: Bool = false
    
    /// delegate for callback data
    public weak var dataDelegate: TimePopoverDataDelegate? = nil
    
    /// The view used to select the date of the log to be viewed.
    public lazy var dateView: SelectDataView = {
        
        let view = SelectDataView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.datePicker.maximumDate = Date()
        
        if let date = dataSource.date {
            view.datePicker.date = date
        }
        
        view.datePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
        
        return view
    }()
    
    /// The view used to select the time period of the log to be viewed.
    public lazy var periodView: SelectPeriodView = {
        
        let view = SelectPeriodView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let period = dataSource.period
        
        view.startPicker.date = period.start
        view.endPicker.date = period.end
        
        view.startPicker.addTarget(self, action: #selector(startPeriodDidChange(_:)), for: .valueChanged)
        view.endPicker.addTarget(self, action: #selector(endPeriodDidChange(_:)), for: .valueChanged)
        
        return view
    }()
    
    /// Confirm button. Used to submit the date and time selected by the user.
    public lazy var doneButton: UIButton = {
        
        let button = UIButton(type: .custom)
        
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .theme
        
        button.layer.cornerRadius = 22
        
        button.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
        
        return button
    }()
    
    public override var height: CGFloat {
        
        let con = BasePopover.Constant.self
        
        return con.topBottomSpacing * 2
             + con.spacing * 2
             + con.itemHeight * 3
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.alignment = .center
        
        addSubviews()
        addInitialLayout()
    }
}

// MARK: - Config

@available(iOS 14.0, *)
private extension TimePopover {
    
    func addSubviews() {
        
        stackView.addArrangedSubview(dateView)
        stackView.addArrangedSubview(periodView)
        stackView.addArrangedSubview(doneButton)
    }
    
    func addInitialLayout() {
        
        [dateView, periodView, doneButton].forEach {
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 44),
                $0.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9)
            ])
        }
    }
}

// MARK: - Action

@available(iOS 14.0, *)
private extension TimePopover {
    
    @objc func datePickerDidChange(_ picker: UIDatePicker) {
        isDataChanged = true
        dataSource.date = picker.date
    }
    
    @objc func startPeriodDidChange(_ picker: UIDatePicker) {
        isDataChanged = true
        dataSource.period.start = picker.date
    }
    
    @objc func endPeriodDidChange(_ picker: UIDatePicker) {
        isDataChanged = true
        dataSource.period.end = picker.date
    }
    
    @objc func doneButtonDidClick(_ button: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
        if isDataChanged {
            dataDelegate?.timePopover(self, didChangedViewedLogDate: dataSource)
        }
    }
}
