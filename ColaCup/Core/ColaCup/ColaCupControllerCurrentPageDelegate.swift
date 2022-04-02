//
//  ColaCupControllerCurrentPageDelegate.swift
//  ColaCup
//
//  Created by Rakuyo on 2021/9/29.
//  Copyright © 2021 Rakuyo. All rights reserved.
//

import Foundation

public protocol ColaCupControllerCurrentPageDelegate: NSObjectProtocol {
    ///  Whether to use the built-in `appear` and `disappear` methods to filter which logs belong to the current page.
    ///
    /// The default is `false`. if you use both logging methods, please implement this method and return `true` to improve the accuracy of the filtering results.
    ///
    /// Also, you need to make sure that the class name and the file name of the controller are the same.
    /// For example, if the controller class name is "ViewController",
    /// then the file name should be "ViewController.swift".
    /// Otherwise it will also cause filtering errors.
    ///
    /// - Parameter controller: ColaCupController
    func usedJumpFlagToFilterCurrentPageOfColaCup(_ controller: ColaCupController) -> Bool
    
    /// Needs to return the name of the file where the user was viewing the controller before entering the cup.
    ///
    /// This method will be used to implement the "Find the log of the current page" function.
    /// If you do not implement this method, then you will not be able to use this function.
    ///
    /// - Parameter controller: ColaCupController
    func nameOfFileBeforeEnterColaCup(_ controller: ColaCupController) -> String
}

public extension ColaCupControllerCurrentPageDelegate {
    func usedJumpFlagToFilterCurrentPageOfColaCup(_ controller: ColaCupController) -> Bool {
        return false
    }
}
