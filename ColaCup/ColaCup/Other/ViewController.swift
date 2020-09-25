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
        
        _ = tableView(tableView: nil, cellForRowAt: nil)
        
        let json = """
        [
            {
                "key_1" : "string",
                "key_2" : 3.1415926,
                "key_3" : -50,
                "key_4" : [],
                "key_5" : {},
                "key_6" : {
                    "key_6_1" : null,
                    "key_6_2" : [
                        "array_1",
                        3.1415926,
                        -50,
                        true,
                        false,
                        null,
                        {},
                        {
                            "some_key" : "some_value"
                        }
                    ],
                    "key_6_3" : {
                        "bool_1" : true,
                        "bool_2" : false,
                        "empty_string" : ""
                    }
                }
            },
            {
                "some_key" : "A very very very very very very very very very very long string."
            },
            {
                {123456}
            }
        ]
        """
        
        Log.debug(json)
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
    
    open func tableView(tableView: UITableView?, cellForRowAt indexPath: IndexPath?) -> UITableViewCell? {
        
        Log.debug("Try this length")
        
        return nil
    }
}
