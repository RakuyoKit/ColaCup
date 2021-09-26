//
//  BasePickerController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class BasePickerController: UIViewController {
    
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
}

extension BasePickerController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(toolBar)
        
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: view.topAnchor),
            toolBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            toolBar.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
        
        toolBar.setContentHuggingPriority(.required, for: .vertical)
    }
}

// MARK: - Config

private extension BasePickerController {
    
    func configAnimation() {
        
        modalPresentationStyle = .custom
        
        // Set the animation agent to itself,
        // so that regardless of any external controller displaying the controller,
        // the identity of the animation will be guaranteed
        transitioningDelegate = self
    }
}

// MARK: - Action

extension BasePickerController {
    
    @objc private func cancelButtonDidClick() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc open func doneButtonDidClick() {
        
        dismiss(animated: true, completion: nil)
        
        
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension BasePickerController: UIViewControllerTransitioningDelegate {
    
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

