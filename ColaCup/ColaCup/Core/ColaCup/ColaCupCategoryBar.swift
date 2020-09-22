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
        view.backgroundColor = .red
        
        return view
    }()
    
    /// View the view of the log flag.
    open lazy var flagCollectionView: UICollectionView = {
        
        let flagCollectionView = UICollectionView()
        
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
