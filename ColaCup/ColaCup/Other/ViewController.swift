//
//  ViewController.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.debug("debug log")
        Log.warning("warning log")
        Log.success("success log")
        Log.error("error log")
        Log.javascript("javascript log")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Log.appear(self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Log.disappear(self)
    }
    
    @IBAction func enterColaCup(_ sender: Any) {
        
        let controller = ColaCupController(logManager: Log.self)
        
        // Show ColaCupController
        present(UINavigationController(rootViewController: controller), animated: true, completion: nil)
    }
}
