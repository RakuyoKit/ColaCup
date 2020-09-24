//
//  ColaCupFlagBar.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/22.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// View to display the flag of logs.
open class ColaCupFlagBar: UIView {
    
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
    
    /// Responsible for scrolling.
    open lazy var scrollView: UIScrollView = {
        
        let view = UIScrollView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.scrollsToTop = false
        
        let padding = ColaCupFlagBar.padding
        
        view.contentInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        
        return view
    }()
    
    /// The parent view of flags, and its child views are all of the type `LogFlagButton`.
    open lazy var stackView: UIStackView = {
        
        let view = UIStackView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = ColaCupFlagBar.padding
        
        return view
    }()
}

extension ColaCupFlagBar {
    
    /// Set up the data source.
    ///
    /// - Parameter _flags: The flags to be displayed
    open func setFlags(_ _flags: [ColaCupSelectedModel]) {
        
        for i in 0 ..< _flags.count {
            
            let flag = _flags[i]
            let button = LogFlagButton()
            
            button.tag = i
            button.titleLabel.text = flag.title
            button.isSelected = flag.isSelected
            
            stackView.addArrangedSubview(button)
            
            button.setContentHuggingPriority(.required, for: .horizontal)
            button.setContentHuggingPriority(.required, for: .vertical)
        }
    }
    
    /// Refresh data.
    ///
    /// - Parameter flags: New data source.
    open func reloadData(flags: [ColaCupSelectedModel]) {
        
        let diff = flags.count - stackView.arrangedSubviews.count
        
        if diff > 0 {
            for _ in 0 ..< diff {
                
                let button = LogFlagButton()
                
                stackView.addArrangedSubview(button)
                
                button.setContentHuggingPriority(.required, for: .horizontal)
                button.setContentHuggingPriority(.required, for: .vertical)
            }
        }
        
        for i in 0 ..< flags.count {
            
            let button = stackView.arrangedSubviews[i] as? LogFlagButton
            
            button?.tag = i
            button?.isHidden = false
            button?.titleLabel.text = flags[i].title
            button?.isSelected = flags[i].isSelected
        }
        
        // Hide redundant views
        guard diff != 0 else { return }
        
        let count = stackView.arrangedSubviews.count
        
        for i in (count + diff) ..< count {
            stackView.arrangedSubviews[i].isHidden = true
        }
    }
}

// MARK: - Config

private extension ColaCupFlagBar {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(scrollView)
        scrollView.addSubview(stackView)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: rightAnchor),
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
        ])
        
        stackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .vertical)
    }
}

public extension ColaCupFlagBar {
    
    static let padding: CGFloat = 8
}

extension ColaCupFlagBar {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard bounds != .zero else { return }
        
        // update frame
        if let mask = layer.mask {
            mask.frame = bounds
            return
        }
        
        // Add a mask layer
        layer.mask = addMaskLayer(withFrame: bounds)
    }
}

// MARK: - Tools

private extension ColaCupFlagBar {
    
    /// Configure the mask layer
    func addMaskLayer(withFrame frame: CGRect) -> CAGradientLayer {
        
        let maskLayer = CAGradientLayer()
        maskLayer.frame = frame
        
        let padding: CGFloat = ColaCupFlagBar.padding
        
        let firstBoundaryLine = padding / frame.size.width
        let secondBoundaryLine = (frame.size.width - padding) / frame.size.width
        
        maskLayer.locations = [(0), (firstBoundaryLine), (secondBoundaryLine), (1)] as [NSNumber]
        
        let colors: [UIColor] = [ .clear, .black, .black, .clear ]
        maskLayer.colors = colors.map { $0.cgColor }
        
        maskLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        maskLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        return maskLayer
    }
}
