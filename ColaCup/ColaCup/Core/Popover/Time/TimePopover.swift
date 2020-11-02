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
        
        self.date = dataSource.date ?? Date()
        
        let config: (TimeInterval) -> (Int, Int) = {
            
            let diff = $0 - dataSource.zeroHour
            let hour = Int(diff / 60 / 60)
            return (hour, Int((diff - TimeInterval(hour * 60 * 60)) / 60))
        }
        
        self.start = config(dataSource.startInterval)
        self.end = config(dataSource.endInterval)
        
        super.init(position: position)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Currently displayed date.
    private var date: Date
    
    /// Currently selected start time.
    private var start: (hour: Int, minute: Int) {
        didSet {
            periodView.startView.timeLabel.text = String(format: "%02zd:%02zd", start.hour, start.minute)
            
            isDataChanged = true
            doneButton.isEnabled = !((start.hour > end.hour)
                                        || (start.hour == end.hour && start.minute > end.minute))
        }
    }
    
    /// Currently selected end time
    private var end: (hour: Int, minute: Int) {
        didSet {
            periodView.endView.timeLabel.text = String(format: "%02zd:%02zd", end.hour, end.minute)
            
            isDataChanged = true
            doneButton.isEnabled = !((start.hour > end.hour)
                                        || (start.hour == end.hour && start.minute > end.minute))
        }
    }
    
    /// Whether the tag data has changed.
    private lazy var isDataChanged: Bool = false
    
    /// delegate for callback data
    public weak var dataDelegate: TimePopoverDataDelegate? = nil
    
    /// The view used to select the date of the log to be viewed.
    public lazy var dateView: SelectDataView = {
        
        let view = SelectDataView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.titleLabel.text = "Date"
        
        if #available(iOS 13.4, *) {
            view.datePicker.date = date
            view.datePicker.maximumDate = Date()
            view.datePicker.addTarget(self, action: #selector(datePickerDidChange(_:)), for: .valueChanged)
            
        } else {
            view.showDateView.dateLabel.text = dateFormatter.string(from: date)
            view.showDateView.addTarget(self, action: #selector(showDateViewDidClick(_:)), for: .touchUpInside)
        }
        
        return view
    }()
    
    /// View to show time period.
    public lazy var periodView: SelectPeriodView = {
        
        let view = SelectPeriodView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.titleLabel.text = "Period"
        
        view.startView.timeLabel.text = String(format: "%02zd:%02zd", start.hour, start.minute)
        view.startView.addTarget(self, action: #selector(startViewDidClick(_:)), for: .touchUpInside)
        
        view.endView.timeLabel.text = String(format: "%02zd:%02zd", end.hour, end.minute)
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
    
    /// Used to format the date
    @available(iOS, deprecated: 13.4)
    private lazy var dateFormatter: DateFormatter = {
        
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter
    }()
}

public extension TimePopover {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.alignment = .center
        
        addSubviews()
        addInitialLayout()
    }
}

// MARK: - Config

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

private extension TimePopover {
    
    @available(iOS 13.4, *)
    @objc func datePickerDidChange(_ picker: UIDatePicker) {
        isDataChanged = true
        date = picker.date
    }
    
    @available(iOS, deprecated: 13.4)
    @objc func showDateViewDidClick(_ view: ShowDateView) {
        
        view.isSelected = true
        
        
    }
    
    @objc func startViewDidClick(_ view: ShowTimeView) {
        
        view.isSelected = true
        
        let controller = TimePickerController()
        
        controller.selectHour = start.hour
        controller.selectMinute = start.minute
        controller.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    @objc func endViewDidClick(_ view: ShowTimeView) {
        
        view.isSelected = true
        
        let controller = TimePickerController()
        
        controller.selectHour = end.hour
        controller.selectMinute = end.minute
        controller.delegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    @objc func doneButtonDidClick(_ button: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
        if isDataChanged {
            
            dataDelegate?.timePopover(self,
                didChangedViewedLogDate: TimePopoverModel(date: date, start: start, end: end)
            )
        }
    }
}

// MARK: - PickerDelegate

extension TimePopover: PickerDelegate {
    
    public func pickerWillDisappear(_ controller: BasePickerController) {
        
        if periodView.startView.isSelected {
            periodView.startView.isSelected = false
        }
        
        if periodView.endView.isSelected {
            periodView.endView.isSelected = false
        }
    }
}

// MARK: - TimePickerDelegate

extension TimePopover: TimePickerDelegate {
    
    public func timePicker(_ controller: TimePickerController, didSelectHour hour: Int, minute: Int) {
        
        if periodView.startView.isSelected {
            start = (hour, minute)
            
        } else if periodView.endView.isSelected {
            end = (hour, minute)
        }
    }
}
