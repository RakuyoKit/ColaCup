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
    
    /// Initialization method
    ///
    /// - Parameters:
    ///   - y: Y coordinate of trigger point
    ///   - itemHeight: Height of each item
    ///   - spacing: Padding between section
    ///   - count: Number of items
    init(y: CGFloat, itemHeight: CGFloat, spacing: CGFloat, count: Int) {
        self.appearY = y
        self.totalHeight = itemHeight * CGFloat(count + 1) + spacing
    }
    
    /// Y coordinate of the point.
    private let appearY: CGFloat
    
    /// The total height of the pop-up.
    private let totalHeight: CGFloat
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        
        toView.frame = CGRect(
            x: containerView.frame.width / 3 * 1 - 10,
            y: appearY + 10,
            width: containerView.frame.width / 3 * 2,
            height: totalHeight
        )
        
        let oldFrame = toView.frame
        toView.layer.anchorPoint = CGPoint(x: 0.9, y: 0)
        toView.frame = oldFrame
        
        toView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        
        toView.alpha = 0
        
        toView.layer.cornerRadius = 10
        toView.layer.masksToBounds = true
        
        containerView.addSubview(toView)
        
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOpacity = 0.35
        containerView.layer.shadowRadius = 10
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveLinear, animations: {

            toView.transform = CGAffineTransform(scaleX: 1, y: 1)
            toView.alpha = 1

        }, completion: { _ in
            
            toView.transform = .identity
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

            fromView.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
            fromView.alpha = 0

        }, completion: { _ in
            
            let isComplete = !transitionContext.transitionWasCancelled
            
            if isComplete {
                fromView.isHidden = true
                fromView.transform = .identity
                fromView.removeFromSuperview()
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
