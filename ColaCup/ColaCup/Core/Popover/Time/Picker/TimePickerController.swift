//
//  TimePickerController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class TimePickerController: UIViewController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        
        configAnimation()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Top toolbar.
    open lazy var toolBar: UIToolbar = {
        
        let bar = UIToolbar()
        
        bar.translatesAutoresizingMaskIntoConstraints = false
        bar.tintColor = .theme
        
        bar.items = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonDidClick)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonDidClick)),
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
    
    func configAnimation() {
        
        modalPresentationStyle = .custom
        
        // Set the animation agent to itself,
        // so that regardless of any external controller displaying the controller,
        // the identity of the animation will be guaranteed
        transitioningDelegate = self
    }
    
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

// MARK: - Action

private extension TimePickerController {
    
    @objc func cancelButtonDidClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func doneButtonDidClick() {
        
        dismiss(animated: true, completion: nil)
        
        
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

// MARK: - UIViewControllerTransitioningDelegate

extension TimePickerController: UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return PickerPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PickerAppearAnimation()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PickerDisappearAnimation()
    }
}
