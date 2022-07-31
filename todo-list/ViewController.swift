//
//  ViewController.swift
//  todo-list
//
//  Created by Алексей Поляков on 30.07.2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let fileCache = FileCache()

        do {
            try fileCache.addTodoItem(id: "123a1111", text: "test text1", priority: .high, deadline: Date.now)
            try fileCache.addTodoItem(id: "123a", text: "test text2", priority: .normal, deadline: Date.now)
            try fileCache.addTodoItem(id: "123aa444", text: "test text3", priority: .normal)
            try fileCache.addTodoItem(id: "123a", text: "test text2", priority: .normal, deadline: Date.now)
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try fileCache.saveFile(fileName: "todo.json")
            try fileCache.loadFile(fileName: "todo.json")
        } catch {
            print(error.localizedDescription)
        }
        
        
    }


}

