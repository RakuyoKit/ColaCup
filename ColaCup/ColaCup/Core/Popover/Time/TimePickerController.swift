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
        
        return bar
    }()
    
    /// The picker used to select the time.
    open lazy var pickerView: UIPickerView = {
        
        let view = UIPickerView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
}

extension TimePickerController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
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
