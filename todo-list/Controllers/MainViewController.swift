//
//  MainViewController.swift
//  todo-list
//
//  Created by Алексей Поляков on 31.07.2022.
//

import UIKit

final class MainViewController: UIViewController {
    
    private lazy var startButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Старт", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(addTodo), for: .touchUpInside)
        
        return button
    }()
    
    @objc
    func addTodo() {
        let todo = TodoItemViewController()
        self.present(UINavigationController(rootViewController: todo), animated: false)
        //self.present(todo, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        view.addSubview(startButton)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            startButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            startButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            startButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
}
