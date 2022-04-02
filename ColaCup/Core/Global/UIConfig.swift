//
//  UIConfig.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/23.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

/// Only manage colors that are used multiple times in components
extension UIColor {
    /// Theme colors in components
    static let theme = UIColor(red: 0.91, green: 0.13, blue: 0.23, alpha: 1.00)
    
    /// Text color in general
    static let normalText = UIColor(red: 0.21, green: 0.00, blue: 0.01, alpha: 1.00)
    
    static var labelColor: UIColor {
        guard #available(iOS 13.0, *) else { return .black }
        return .label
    }
    
    static var systemBackgroundColor: UIColor {
        guard #available(iOS 13.0, *) else { return .white }
        return .systemBackground
    }
    
    static var systemGroupedBackgroundColor: UIColor {
        guard #available(iOS 13.0, *) else { return .groupTableViewBackground }
        return .systemGroupedBackground
    }
}

extension UIImage {
    convenience init?(name: String) {
        if #available(iOS 13.0, *), UIImage(systemName: name) != nil {
            self.init(systemName: name)
            
        } else {
            if let resourcePath = Bundle(for: type(of: self)).resourcePath,
               let bundle = Bundle(path: resourcePath + "/ColaCupBundle.bundle") {
                
                self.init(named: name, in: bundle, compatibleWith: nil)
                
            } else {
                self.init(named: name)
            }
        }
    }
}
