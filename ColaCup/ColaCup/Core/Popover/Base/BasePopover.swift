//
//  BasePopover.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/16.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

public protocol ColaCupPopoverDelegate: class {
    
    /// Execute when the pop-up is about to disappear.
    ///
    /// - Parameter popover: The currently displayed pop-up.
    func popoverWillDisappear<Popover: BasePopover>(_ popover: Popover)
}

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
    
    /// Controller delegate.
    public weak var delegate: ColaCupPopoverDelegate? = nil
    
    /// The parent view of all the following views.
    open lazy var stackView: UIStackView = {
        
        let view = UIStackView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.axis = .vertical
        view.alignment = .fill
        view.distribution = .equalSpacing
        view.spacing = Constant.spacing
        
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
        
        let space = Constant.topBottomSpacing
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: space),
            stackView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -space),
            stackView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.popoverWillDisappear(self)
    }
}

// MARK: - Config

extension BasePopover {
    
    enum Constant {
        
        /// The spacing of each item in `stackView`.
        static let spacing: CGFloat = 15
        
        /// `stackView` top and bottom spacing.
        static let topBottomSpacing: CGFloat = 10
    }
}

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
