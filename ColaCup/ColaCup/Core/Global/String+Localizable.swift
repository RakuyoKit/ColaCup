//
//  String+Localizable.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/29.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

extension String {
    var locale: String {
        if let resourcePath = Bundle(for: ColaCupController.self).resourcePath,
           let bundle = Bundle(path: resourcePath + "/ColaCupBundle.bundle") {
            return NSLocalizedString(self, bundle: bundle, comment: "")
        }
        return NSLocalizedString(self, comment: "")
    }
}
