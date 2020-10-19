//
//  BasePopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/16.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class BasePopover: UIViewController {
    
    /// Initialization method.
    ///
    /// - Parameter position: The position to be displayed.
    init(position: CGPoint) {
        self.appearPosition = position
        
        super.init(nibName: nil, bundle: nil)
        
        configAnimation()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The position to be displayed.
    private let appearPosition: CGPoint
    
    /// The parent view of all the following views.
    open lazy var stackView: UIStackView = {
        
        let view = UIStackView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = 15
        
        return view
    }()
}

extension BasePopover {
    
    /// The height of the pop-up.
    ///
    /// Need to be overwritten by subclasses to return the exact height.
    @objc open var height: CGFloat { 0 }
}

// MARK: - Life cycle

extension BasePopover {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGroupedBackground
        } else {
            view.backgroundColor = .groupTableViewBackground
        }
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}

// MARK: - Config

private extension BasePopover {
    
    func configAnimation() {
        
        modalPresentationStyle = .custom
        
        // Set the animation agent to itself,
        // so that regardless of any external controller displaying the controller,
        // the identity of the animation will be guaranteed
        transitioningDelegate = self
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension BasePopover: UIViewControllerTransitioningDelegate {
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return PopoverPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PopoverAppearAnimation(position: appearPosition, height: height)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {

        return PopoverDisappearAnimation()
    }
}
