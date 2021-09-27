//
//  Sort.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/26.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

/// Sort order of logs
public enum Sort {
    case positive
    case negative
}

public extension Sort {
    static let `default`: Sort = .negative
}

public extension Sort {
    var title: String {
        switch self {
        case .positive: return "Positive"
        case .negative: return "Negative"
        }
    }
}

// MARK: - Equatable

extension Sort: Equatable {}
