//
//  ColaCupLoadingView.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// A view that shows that a task is in progress.
open class ColaCupLoadingView: UIView {
    public init() {
        super.init(frame: .zero)
        config()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    open lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        
        return view
    }()
    
    open lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: {
            if #available(iOS 13.0, *) { return .large }
            return .whiteLarge
        }())
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = false
        
        return view
    }()
}

extension ColaCupLoadingView {
    open func show() {
        guard isHidden else { return }
        
        activityIndicator.startAnimating()
        
        alpha = 0
        isHidden = false
        
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 1
            self.visualEffectView.effect = UIBlurEffect(style: .light)
            
        }, completion: { _ in })
    }
    
    open func hide() {
        guard !isHidden else { return }
        
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
            self.visualEffectView.effect = nil
            
        }, completion: { _ in
            self.isHidden = true
            self.activityIndicator.stopAnimating()
        })
    }
}

// MARK: - Config

private extension ColaCupLoadingView {
    func config() {
        isHidden = true
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.color = .theme
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        addSubview(visualEffectView)
        addSubview(activityIndicator)
    }
    
    func addInitialLayout() {
        NSLayoutConstraint.activate([
            visualEffectView.heightAnchor.constraint(equalToConstant: 90),
            visualEffectView.widthAnchor.constraint(equalToConstant: 90),
            visualEffectView.centerYAnchor.constraint(equalTo: centerYAnchor),
            visualEffectView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: visualEffectView.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: visualEffectView.centerXAnchor),
        ])
        
        activityIndicator.setContentHuggingPriority(.required, for: .vertical)
        activityIndicator.setContentHuggingPriority(.required, for: .horizontal)
    }
}
