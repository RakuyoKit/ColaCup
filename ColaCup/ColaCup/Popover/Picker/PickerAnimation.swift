//
//  PickerAnimation.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

// MARK: - Appear

class PickerAppearAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to) else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView
        
        // Use a fixed height
        // It is convenient to directly click on the cell when holding the phone with one hand
        let height: CGFloat = 280
        
        let screenSize = UIScreen.main.bounds.size
        
        toView.frame.origin = CGPoint(x: 0, y: screenSize.height)
        toView.frame.size = CGSize(width: screenSize.width, height: height)
        
        containerView.addSubview(toView)
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            toView.frame.origin.y = screenSize.height - height
            
        }, completion: { _ in
            transitionContext.completeTransition(true)
        })
    }
}

// MARK: - Disappear

class PickerDisappearAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        
        let finalY = transitionContext.containerView.frame.maxY
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, animations: {
            
            fromView.frame.origin.y = finalY
            
        }, completion: { _ in
            
            let isComplete = !transitionContext.transitionWasCancelled
            
            if isComplete {
                fromView.removeFromSuperview()
            }
            
            transitionContext.completeTransition(isComplete)
        })
    }
}

// MARK: - Presentation Controller

class PickerPresentationController: UIPresentationController {
    
    private lazy var backgroundView: UIView = {
        
        let view = UIView()
        
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissController(_:))))
        
        return view
    }()
}

extension PickerPresentationController {
    
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
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            
            self.backgroundView.alpha = 1
            
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            
            self.backgroundView.alpha = 0
            
        }, completion: nil)
    }
}

private extension PickerPresentationController {
    
    @objc func dismissController(_ recognizer: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
