//
//  TimePopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/19.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Delegate for callback data.
public protocol TimePopoverDataDelegate: class {
    
    /// The callback executed after the user clicks the OK button on the pop-up.
    ///
    /// - Parameters:
    ///   - popover: `TimePopover`.
    ///   - model: Modified model.
    func timePopover(_ popover: TimePopover, didChangedViewedLogDate model: TimePopoverModel)
}

/// A pop-up window for displaying time options.
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
    @available(iOS 13.4, *)
    public lazy var dateView: SelectDataView = {
        
        let view = SelectDataView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.titleLabel.text = "Date"
        view.datePicker.maximumDate = Date()
        
        if let date = dataSource.date {
            view.datePicker.date = date
        }
        
        view.datePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
        
        return view
    }()
    
    /// View to show time period.
    public lazy var periodView: SelectPeriodView = {
        
        let view = SelectPeriodView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.titleLabel.text = "Period"
        view.startView.timeLabel.text = "00:00"
        view.endView.timeLabel.text = "24:00"
        
        view.startView.addTarget(self, action: #selector(startViewDidClick(_:)), for: .touchUpInside)
        view.endView.addTarget(self, action: #selector(endViewDidClick(_:)), for: .touchUpInside)
        
        return view
    }()
    
    /// Confirm button. Used to submit the date and time selected by the user.
    public lazy var doneButton: UIButton = {
        
        let button = UIButton(type: .system)
        
        button.backgroundColor = .theme
        button.layer.cornerRadius = 22
        
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        
        button.setTitle("Time range error", for: .disabled)
        button.setTitleColor(.lightGray, for: .disabled)
        
        button.addTarget(self, action: #selector(doneButtonDidClick(_:)), for: .touchUpInside)
        
        return button
    }()
    
    public override var height: CGFloat {
        
        let con = BasePopover.Constant.self
        
        let itemCount: CGFloat = 3
        
        return con.topBottomSpacing * 2
             + con.spacing * (itemCount - 1)
             + con.itemHeight * itemCount
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.alignment = .center
        
        addSubviews()
        addInitialLayout()
    }
}

// MARK: - Config

private extension TimePopover {
    
    /// Under the current system, the available dateView.
    var availableDateView: UIView {
        if #available(iOS 13.4, *) { return dateView } else { return UIView() }
    }
}

private extension TimePopover {
    
    func addSubviews() {
        
        stackView.addArrangedSubview(availableDateView)
        stackView.addArrangedSubview(periodView)
        stackView.addArrangedSubview(doneButton)
    }
    
    func addInitialLayout() {
        
        [availableDateView, periodView, doneButton].forEach {
            NSLayoutConstraint.activate([
                $0.heightAnchor.constraint(equalToConstant: 44),
                $0.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.9)
            ])
        }
    }
}

// MARK: - Action

private extension TimePopover {
    
    @objc func datePickerDidChange(_ picker: UIDatePicker) {
        isDataChanged = true
        dataSource.date = picker.date
    }
    
    @objc func startViewDidClick(_ view: ShowTimeView) {
        
        view.isSelected = true
        
        let controller = TimePickerController()
        
        present(controller, animated: true, completion: nil)
    }
    
    @objc func endViewDidClick(_ view: ShowTimeView) {
        
        view.isSelected = true
        
        let controller = TimePickerController()
        
        present(controller, animated: true, completion: nil)
    }
    
//    @objc func startPeriodDidChange(_ picker: UIDatePicker) {
//
//        let date = picker.date
//
//        if date < dataSource.period.end {
//            isDataChanged = true
//            dataSource.period.start = date
//
//            doneButton.isEnabled = true
//
//        } else {
//            doneButton.isEnabled = false
//        }
//    }
//
//    @objc func endPeriodDidChange(_ picker: UIDatePicker) {
//
//        let date = picker.date
//
//        if date > dataSource.period.start {
//            isDataChanged = true
//            dataSource.period.end = date
//
//            doneButton.isEnabled = true
//
//        } else {
//            doneButton.isEnabled = false
//        }
//    }
    
    @objc func doneButtonDidClick(_ button: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
        if isDataChanged {
            dataDelegate?.timePopover(self, didChangedViewedLogDate: dataSource)
        }
    }
}
