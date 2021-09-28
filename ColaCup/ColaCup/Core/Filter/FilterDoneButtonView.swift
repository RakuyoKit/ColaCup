//
//  FilterDoneButtonView.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

/// Filter page, done button at the bottom.
open class FilterDoneButtonView: UIView {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        config()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        config()
    }
    
    open lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        button.setTitle("Show Result", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)
        
        button.setBackgroundImage(.init(color: .theme), for: .normal)
        button.setBackgroundImage(.init(color: UIColor.theme.withAlphaComponent(0.85)), for: .disabled)
        
        button.setTitleColor(.systemBackgroundColor, for: .normal)
        button.setTitleColor(.systemBackgroundColor.withAlphaComponent(0.85), for: .disabled)
        
        return button
    }()
}

// MARK: - Config

private extension FilterDoneButtonView {
    func config() {
        backgroundColor = .systemBackgroundColor
        
        addSubviews()
        addInitialLayout()
    }
    
    func addSubviews() {
        addSubview(doneButton)
    }
    
    func addInitialLayout() {
        var _view: (
            leadingAnchor: NSLayoutXAxisAnchor,
            trailingAnchor: NSLayoutXAxisAnchor,
            bottomAnchor: NSLayoutYAxisAnchor
        )
        
        if #available(iOS 11.0, *) {
            _view = (safeAreaLayoutGuide.leadingAnchor, safeAreaLayoutGuide.trailingAnchor, safeAreaLayoutGuide.bottomAnchor)
        } else {
            _view = (leadingAnchor, trailingAnchor, bottomAnchor)
        }
        
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: 44),
            doneButton.topAnchor.constraint(equalTo: topAnchor, constant: 15),
            doneButton.leadingAnchor.constraint(equalTo: _view.leadingAnchor, constant: 15),
            doneButton.trailingAnchor.constraint(equalTo: _view.trailingAnchor, constant: -15),
            doneButton.bottomAnchor.constraint(equalTo: _view.bottomAnchor, constant: -15),
        ])
    }
}

fileprivate extension UIImage {
    convenience init?(color: UIColor) {
        let size = CGSize(width: 1, height: 1)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer { UIGraphicsEndImageContext() }
        
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        ctx.setFillColor(color.cgColor)
        ctx.fill(CGRect(origin: .zero, size: size))
        
        guard let cgImage = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { return nil }
        
        self.init(cgImage: cgImage)
    }
}
