//
//  TimePickerController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class TimePickerController: BasePickerController {
    
    /// The picker used to select the time.
    open lazy var pickerView: UIPickerView = {
        
        let view = UIPickerView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.delegate = self
        view.dataSource = self
        
        return view
    }()
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
}

// MARK: - Action

extension TimePickerController {
    
    @objc open override func doneButtonDidClick() {
        super.doneButtonDidClick()
        
        
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
