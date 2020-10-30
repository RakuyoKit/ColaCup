//
//  TimePickerController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class TimePickerController: UIViewController {
    
    /// Top toolbar.
    open lazy var toolBar: UIToolbar = {
        
        let bar = UIToolbar()
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.tintColor = .theme
        
        bar.items = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: nil),
        ]
        
        return bar
    }()
    
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
        
        view.backgroundColor = .white
        
        addSubviews()
        addInitialLayout()
    }
}

// MARK: - Config

private extension TimePickerController {
    
    func addSubviews() {
        
        view.addSubview(toolBar)
        view.addSubview(pickerView)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: view.topAnchor),
            toolBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        toolBar.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: toolBar.bottomAnchor),
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pickerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            pickerView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
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
