//
//  VeryVeryVeryVeryVeryVeryLongFileName.swift
//  ColaCup
//
//  Created by Rakuyo on 2020/9/21.
//  Copyright © 2020 Rakuyo. All rights reserved.
//

import UIKit

import RaLog

class ViewController: UIViewController {

    private lazy var enter: Void = {
        enterColaCup(self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.debug(1234567890)
        Log.debug("Test a very very long log to see what the final effect will look like.")
        Log.debug("顺带再测试一下中文的效果\n实际上的日志基本上都会是这个长度的\n甚至还要再长一点\n毕竟有的时候一行打不下\n现在需要测试一下高度\n非常非常\n高的情况\n可能会比\n一个屏幕\n还要高\n这种情况\n下\n复用问题\n会不会\n有问题\n呢\n顺带再测试一下中文的效果\n实际上的日志基本上都会是这个长度的\n甚至还要再长一点\n毕竟有的时候一行打不下\n现在需要测试一下高度\n非常非常\n高的情况\n可能会比\n一个屏幕\n还要高\n这种情况\n下\n复用问题\n会不会\n有问题\n呢\n顺带再测试一下中文的效果\n实际上的日志基本上都会是这个长度的\n甚至还要再长一点\n毕竟有的时候一行打不下\n现在需要测试一下高度\n非常非常\n高的情况\n可能会比\n一个屏幕\n还要高\n这种情况\n下\n复用问题\n会不会\n有问题\n呢\n")
        Log.warning("warning log")
        Log.success("success log")
        Log.error("error log")
        Log.javascript("javascript log")
        
        Log.debug("\n\nTry line breaks and spaces. \n\n So what?  ")
        
        _ = tableView(tableView: nil, cellForRowAt: nil)
        
        let json = """
        Some useless text.
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
                        "stackoverflow.com",
                        "http://www.apple.com",
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
                        "empty_string" : "",
                        "url" : "172.168.0.1",
                        "test_url_escaping" : "https:\\/\\/www.github.com"
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
        Some useless text~
        """
        
        Log.debug(json)
        Log.debug("15:34:43:310")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Log.appear(self)
        
        _ = enter
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Log.disappear(self)
    }
    
    @IBAction func enterColaCup(_ sender: Any) {
        
        let controller = ColaCupController(logManager: Log.self)
        
        let navi = UINavigationController(rootViewController: controller)
        
        navi.modalPresentationStyle = .fullScreen
        
        // Show ColaCupController
        present(navi, animated: true, completion: nil)
    }
    
    open func tableView(tableView: UITableView?, cellForRowAt indexPath: IndexPath?) -> UITableViewCell? {
        
        Log.debug("Try this length")
        
        return nil
    }
}
