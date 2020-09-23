//
//  ColaCupCategoryBar.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/22.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// View to display the category of logs and the category of modules.
open class ColaCupCategoryBar: UIView {
    
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
    
    /// Button to display the list of modules.
    open lazy var modulesButton: UIButton = {
        
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage(systemName: "list.dash"), for: .normal)
        
        button.setPreferredSymbolConfiguration(UIImage.SymbolConfiguration(pointSize: 25, weight: .unspecified), forImageIn: .normal)
        
        return button
    }()
    
    /// The parent view that hosts the `flagCollectionView`
    private lazy var flagView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    /// View the view of the log flag.
    open lazy var flagCollectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        let flagCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        flagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        flagCollectionView.showsVerticalScrollIndicator = false
        flagCollectionView.showsHorizontalScrollIndicator = false
        
        flagCollectionView.allowsMultipleSelection = true
        flagCollectionView.scrollsToTop = false
        
        return flagCollectionView
    }()
}

// MARK: - Config

private extension ColaCupCategoryBar {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(modulesButton)
        addSubview(flagView)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            modulesButton.leftAnchor.constraint(equalTo: leftAnchor),
            modulesButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
        
        modulesButton.setContentHuggingPriority(.required, for: .horizontal)
        modulesButton.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            flagView.leftAnchor.constraint(equalTo: modulesButton.rightAnchor, constant: 5),
            flagView.rightAnchor.constraint(equalTo: rightAnchor),
            flagView.topAnchor.constraint(equalTo: topAnchor),
            flagView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}

extension ColaCupCategoryBar {
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        guard flagView.bounds != .zero else { return }
        
        // update frame
        if let mask = flagView.layer.mask {
            mask.frame = flagView.bounds
            return
        }
        
        // Add a mask layer
        flagView.layer.mask = addMaskLayer(withFrame: flagView.bounds)
    }
}

// MARK: - Tools

private extension ColaCupCategoryBar {
    
    /// Configure the mask layer
    func addMaskLayer(withFrame frame: CGRect) -> CAGradientLayer {
        
        let maskLayer = CAGradientLayer()
        maskLayer.frame = frame
        
        let layout = flagCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        let padding: CGFloat = layout?.sectionInset.left ?? 0
        
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
