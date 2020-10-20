//
//  PopoverAnimation.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - Appear

class PopoverAppearAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// Initialization method.
    ///
    /// - Parameters:
    ///   - position: The position to be displayed.
    ///   - height: Height of popup.
    init(position: CGPoint, height: CGFloat) {
        self.appearPosition = position
        self.height = height
    }
    
    /// The position to be displayed.
    private let appearPosition: CGPoint
    
    /// Height of popup.
    private let height: CGFloat
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // 1. Create target view.
        guard let toView = createToView(from: transitionContext) else { return }
        
        let containerView = transitionContext.containerView
        
        let width = (containerView.frame.width) / 3 * 2
        
        // 2. Set the frame to the target view.
        toView.frame = CGRect(x: 0, y: appearPosition.y + 10, width: width, height: height)
        toView.center.x = appearPosition.x
        
        // 3. Add shadows to the target views.
        let newView = addShadow(to: toView)
        
        // 4. Set some initial values for animation properties.
        configToViewAnimate(newView)
        
        // 5. Add to the container view.
        containerView.addSubview(newView)
        
        // 6. Start animation.
        startAnimate(with: newView, using: transitionContext)
    }
}

private extension PopoverAppearAnimation {
    
    func createToView(from transitionContext: UIViewControllerContextTransitioning) -> UIView? {
        
        guard let toView = transitionContext.view(forKey: .to) else { return nil }
        
        toView.layer.cornerRadius = 10
        toView.layer.masksToBounds = true
        toView.layer.shouldRasterize = true
        toView.layer.rasterizationScale = UIScreen.main.scale
        
        return toView
    }
    
    func configToViewAnimate(_ view: UIView) {
        
        let oldFrame = view.frame
        view.layer.anchorPoint = CGPoint(x: 0.5, y: 0)
        view.frame = oldFrame
        
        view.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        view.alpha = 0
    }
    
    func addShadow(to view: UIView) -> UIView {
        
        let shadowView = UIView()
        
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowRadius = 10
        shadowView.layer.shadowOpacity = 0.45
        
        shadowView.frame = view.frame
        view.frame.origin = .zero
        
        shadowView.addSubview(view)
        
        return shadowView
    }
    
    func startAnimate(
        with view: UIView,
        using transitionContext: UIViewControllerContextTransitioning
    ) {
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveLinear, animations: {
            
            view.transform = CGAffineTransform(scaleX: 1, y: 1)
            view.alpha = 1
            
        }, completion: { _ in
            
            view.transform = .identity
            transitionContext.completeTransition(true)
        })
    }
}

// MARK: - Disappear

class PopoverDisappearAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.7
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveLinear, animations: {
            
            fromView.superview?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            fromView.superview?.alpha = 0
            
        }, completion: { _ in
            
            let isComplete = !transitionContext.transitionWasCancelled
            
            if isComplete {
                fromView.superview?.isHidden = true
                fromView.superview?.transform = .identity
                fromView.superview?.removeFromSuperview()
            }
            
            transitionContext.completeTransition(isComplete)
        })
    }
}

// MARK: - Presentation Controller

class PopoverPresentationController: UIPresentationController {
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private lazy var keyboardIsVisible: Bool = false
    
    private lazy var backgroundView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss(_:))))
        
        return view
    }()
}

extension PopoverPresentationController {
    
    override var shouldRemovePresentersView: Bool { false }
    
    override func presentationTransitionWillBegin() {
        
        guard let containerView = containerView else { return }
        
        containerView.insertSubview(backgroundView, at: 0)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
    }
}

private extension PopoverPresentationController {
    
    @objc func keyboardDidShow() {
        keyboardIsVisible = true
    }
    
    @objc func keyboardDidHide() {
        keyboardIsVisible = false
    }
    
    @objc func dismiss(_ recognizer: UITapGestureRecognizer) {
        
        if keyboardIsVisible {
            UIApplication.shared.keyWindow?.endEditing(true)
            
        } else {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
}
