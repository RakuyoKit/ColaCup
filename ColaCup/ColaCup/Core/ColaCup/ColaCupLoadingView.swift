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
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    open lazy var activityIndicator: UIActivityIndicatorView = {
        
        let view = UIActivityIndicatorView(style: .medium)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hidesWhenStopped = false
        
        return view
    }()
    
    open override var isHidden: Bool {
        didSet {
            if isHidden {
                activityIndicator.stopAnimating()
            } else {
                activityIndicator.startAnimating()
            }
        }
    }
}

// MARK: - Config

private extension ColaCupLoadingView {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(visualEffectView)
        addSubview(activityIndicator)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: topAnchor),
            visualEffectView.leftAnchor.constraint(equalTo: leftAnchor),
            visualEffectView.rightAnchor.constraint(equalTo: rightAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        activityIndicator.setContentHuggingPriority(.required, for: .vertical)
        activityIndicator.setContentHuggingPriority(.required, for: .horizontal)
    }
}
