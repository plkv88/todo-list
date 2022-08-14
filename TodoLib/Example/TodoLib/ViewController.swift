//
//  ViewController.swift
//  TodoLib
//
//  Created by Aleksey Polyakov on 08/13/2022.
//  Copyright (c) 2022 Aleksey Polyakov. All rights reserved.
//

import UIKit
import TodoLib

@available(iOS 15, *)
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let todoItem = TodoItem(text: "Hello!")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
