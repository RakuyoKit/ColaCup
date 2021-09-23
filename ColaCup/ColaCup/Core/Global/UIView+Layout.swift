//
//  UIView+Layout.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/23.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

public extension UIView {
    enum XAxis {
        case leading
        case trailing
    }
    
    func callAsFunction(xAxis: XAxis, needSafeArea: Bool = true) -> NSLayoutXAxisAnchor {
        switch xAxis {
        case .leading:
            guard _fastPath(needSafeArea), #available(iOS 11.0, *) else { return leadingAnchor }
            return safeAreaLayoutGuide.leftAnchor
            
        case .trailing:
            guard _fastPath(needSafeArea), #available(iOS 11.0, *) else { return trailingAnchor }
            return safeAreaLayoutGuide.trailingAnchor
        }
    }
}

public extension UIView {
    enum YAxis {
        case top
        case bottom
    }
    
    func callAsFunction(yAxis: YAxis, needSafeArea: Bool = true) -> NSLayoutYAxisAnchor {
        switch yAxis {
        case .top:
            guard _fastPath(needSafeArea), #available(iOS 11.0, *) else { return topAnchor }
            return safeAreaLayoutGuide.topAnchor
            
        case .bottom:
            guard _fastPath(needSafeArea), #available(iOS 11.0, *) else { return bottomAnchor }
            return safeAreaLayoutGuide.bottomAnchor
        }
    }
}
