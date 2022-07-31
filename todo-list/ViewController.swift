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
            try fileCache.addTodoItem(todoItem: TodoItem(text: "Привет мир!", priority: .high, deadline: Date.now))
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

