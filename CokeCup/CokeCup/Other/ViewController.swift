//
//  ViewController.swift
//  CokeCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show CokeCupController
        present(UINavigationController(rootViewController: CokeCupController()), animated: true, completion: nil)
    }
}
