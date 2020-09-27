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
    ///   - y: Y coordinate of trigger point.
    ///   - height: Height of popup.
    init(y: CGFloat, height: CGFloat) {
        self.appearY = y
        self.height = height
    }
    
    /// Y coordinate of the point.
    private let appearY: CGFloat
    
    /// Height of popup.
    private let height: CGFloat
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        // 1. Create target view.
        guard let toView = createToView(from: transitionContext) else { return }
        
        let containerView = transitionContext.containerView
        
        // Maximum width is 276.
        let width = min(containerView.frame.width / 3 * 2, 276)
        
        let x = containerView.frame.width - width - 20 - containerView.safeAreaInsets.right
        
        // 2. Set the frame to the target view.
        toView.frame = CGRect(x: x, y: appearY + 10, width: width, height: height)
        
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
        view.layer.anchorPoint = CGPoint(x: 0.9, y: 0)
        view.frame = oldFrame
        
        view.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        view.alpha = 0
    }
    
    func addShadow(to view: UIView) -> UIView {
        
        let shadowView = UIView()
        
        shadowView.backgroundColor = .clear
        shadowView.layer.shadowColor = UIColor.lightGray.cgColor
        shadowView.layer.shadowRadius = 10
        shadowView.layer.shadowOpacity = 0.35
        
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
    
    @objc func dismiss(_ recognizer: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
