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
    
    /// The parent view that hosts the `flagCollectionView`
    private lazy var flagView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    /// View the view of the log flag.
    open lazy var collectionView: UICollectionView = {
        
        let padding = ColaCupFlagBar.collectionViewPadding
        
        let layout = UICollectionViewFlowLayout()
        
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = padding
        layout.sectionInset = UIEdgeInsets(top: 0, left: padding, bottom: 0, right: padding)
        
        let flagCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        flagCollectionView.translatesAutoresizingMaskIntoConstraints = false
        flagCollectionView.backgroundColor = .clear
        
        flagCollectionView.showsVerticalScrollIndicator = false
        flagCollectionView.showsHorizontalScrollIndicator = false
        
        flagCollectionView.allowsMultipleSelection = true
        flagCollectionView.scrollsToTop = false
        
        return flagCollectionView
    }()
}

// MARK: - Config

private extension ColaCupFlagBar {
    
    func config() {
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        
        addSubview(flagView)
        
        flagView.addSubview(collectionView)
    }
    
    func addInitialLayout() {
        
        NSLayoutConstraint.activate([
            flagView.leftAnchor.constraint(equalTo: leftAnchor),
            flagView.rightAnchor.constraint(equalTo: rightAnchor),
            flagView.topAnchor.constraint(equalTo: topAnchor),
            flagView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: flagView.leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: flagView.rightAnchor),
            collectionView.topAnchor.constraint(equalTo: flagView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: flagView.bottomAnchor),
        ])
    }
}

public extension ColaCupFlagBar {
    
    static let collectionViewPadding: CGFloat = 8
}

extension ColaCupFlagBar {
    
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

private extension ColaCupFlagBar {
    
    /// Configure the mask layer
    func addMaskLayer(withFrame frame: CGRect) -> CAGradientLayer {
        
        let maskLayer = CAGradientLayer()
        maskLayer.frame = frame
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
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
