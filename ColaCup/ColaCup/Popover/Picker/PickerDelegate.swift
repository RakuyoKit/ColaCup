//
//  PickerDelegate.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/10/30.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

public protocol PickerDelegate: class {
    
    /// Called when the select controller is about to disappear.
    ///
    /// - Parameter controller: Picker controller to disappear.
    func pickerWillDisappear(_ controller: BasePickerController)
}
