//
//  TimePickerController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

public protocol TimePickerDelegate: PickerDelegate {
    
    /// Called when time is selected.
    ///
    /// - Parameters:
    ///   - controller: `TimePickerController`
    ///   - hour: Selected hour
    ///   - minute: Selected minute
    func timePicker(_ controller: TimePickerController, didSelectHour hour: Int, minute: Int)
}

open class TimePickerController: BasePickerController {
    
    /// Delegate.
    public weak var delegate: TimePickerDelegate? = nil
    
    /// The picker used to select the time.
    open lazy var pickerView: UIPickerView = {
        
        let view = UIPickerView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
    
    /// The currently selected time, hour.
    public lazy var selectHour: Int = 0 {
        didSet {
            pickerView.selectRow(selectHour, inComponent: 0, animated: false)
        }
    }
    
    /// The currently selected time, minute.
    public lazy var selectMinute: Int = 0 {
        didSet {
            pickerView.selectRow(selectMinute, inComponent: 2, animated: false)
        }
    }
}

extension TimePickerController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(pickerView)
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pickerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            pickerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.pickerWillDisappear(self)
    }
}

// MARK: - Action

extension TimePickerController {
    
    @objc open override func doneButtonDidClick() {
        super.doneButtonDidClick()
        
        delegate?.timePicker(self, didSelectHour: selectHour, minute: selectMinute)
    }
}

// MARK: - UIPickerViewDelegate

extension TimePickerController: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        
        return component == 1 ? 44 : (pickerView.frame.size.width - 44) * 0.35
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var label = view as? UILabel
        
        if label == nil {
            
            label = UILabel()
            
            label?.textAlignment = .center
            label?.font = UIFont.systemFont(ofSize: 30)
        }
        
        label?.text = component == 1 ? ":" : String(format: "%02zd", row)
        
        return label!
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if component == 0 {
            selectHour = row
        } else if component == 2 {
            selectMinute = row
        }
    }
}

// MARK: - UIPickerViewDataSource

extension TimePickerController: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch component {
        case 0:  return 24
        case 1:  return 1
        case 2:  return 60
        default: return 0
        }
    }
}
