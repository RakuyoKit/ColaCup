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
        
        Log.debug("Test a very very long log to see what the final effect will look like.")
        Log.debug("顺带再测试一下中文的效果，实际上的日志基本上都会是这个长度的。甚至还要再长一点，毕竟有的时候一行打不下")
        Log.warning("warning log")
        Log.success("success log")
        Log.error("error log")
        Log.javascript("javascript log")
        
        Log.debug("\n\nTry line breaks and spaces. \n\n So what?  ")
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
