//
//  DateAlertController.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/27.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import UIKit

/// Alert controller for time selection.
public class DateAlertController: UIViewController {
    /// Use the currently selected date for initialization.
    ///
    /// - Parameter date: The date currently selected by the user.
    public init(date: Date?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The callback after the user selects the date.
    public lazy var completion: ((Date?) -> Void)? = nil
}
