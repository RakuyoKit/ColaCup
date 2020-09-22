//
//  ViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func enterColaCup(_ sender: Any) {
        
        // Show ColaCupController
        present(UINavigationController(rootViewController: ColaCupController()), animated: true, completion: nil)
    }
}
