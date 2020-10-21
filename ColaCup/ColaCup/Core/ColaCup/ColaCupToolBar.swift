//
//  ColaCupToolBar.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/16.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

open class ColaCupToolBar: UIStackView {
    
    public init() {
        super.init(frame: .zero)
        config()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    /// Close button.
    open lazy var closeButton = UIButton(type: .system)
    
    /// Button to open the time popover.
    open lazy var timeButton = UIButton(type: .system)
    
    /// Button to open the filter popover.
    open lazy var filterButton = UIButton(type: .system)
    
    /// Button to sort log list.
    open lazy var sortButton = UIButton(type: .system)
}

// MARK: - Config

extension ColaCupToolBar {
    
    enum Constant {
        
        /// The size of each button
        static let buttonSize: CGFloat = 40
    }
}

private extension ColaCupToolBar {
    
    func config() {
        
        axis = .horizontal
        alignment = .center
        distribution = .equalSpacing
        
        [
            (closeButton,  "xmark.circle"),
            (timeButton,   "clock"),
            (filterButton, "line.horizontal.3.decrease.circle"),
            (sortButton,   "arrow.clockwise.circle")
        ].forEach {
            
            $0.0.translatesAutoresizingMaskIntoConstraints = false
            $0.0.backgroundColor = .white
            
            $0.0.tintColor = .theme
            $0.0.setImage(UIImage(name: $0.1), for: .normal)
            
            if #available(iOS 13.0, *) {
                $0.0.setPreferredSymbolConfiguration(
                    UIImage.SymbolConfiguration(pointSize: Constant.buttonSize * 0.55),
                    forImageIn: .normal
                )
            }
            
            $0.0.layer.cornerRadius = Constant.buttonSize * 0.5
            
            addArrangedSubview($0.0)
            
            NSLayoutConstraint.activate([
                $0.0.widthAnchor.constraint(equalToConstant: Constant.buttonSize),
                $0.0.heightAnchor.constraint(equalTo: $0.0.widthAnchor)
            ])
        }
    }
}
