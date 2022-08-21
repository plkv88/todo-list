//
//  AuthViewController.swift
//  todo-list
//
//  Created by Алексей Поляков on 21.08.2022.
//

import Foundation
import UIKit
import WebKit

enum AuthType: String {
    case yandexOAuth = "OAuth "
    case bearer = "Bearer "
}

// MARK: - Class


final class AuthViewController: UIViewController {

    // MARK: - Layout
    
    private enum Layout {
        static let backgroundcolor = UIColor(red: 0.97, green: 0.97, blue: 0.95, alpha: 1.0)
        static let title = "Авторизация"
        static let buttonTitle = "Войти без Яндекс.ID"
        static let buttonHeight: CGFloat = 60
        static let cornerRadius: CGFloat = 16
        static let inset: CGFloat = 16
    }

    private let loginUrl =
    "https://oauth.yandex.ru/authorize?response_type=token&client_id=0d0970774e284fa8ba9ff70b6b06479a&force_confirm=yes"

    private var token: String = "ProtectedNecromancy"
    private var authType: AuthType = .bearer

    // MARK: - Subviews
    
    private lazy var noAuthButton: UIButton = {
        let button = UIButton()
        button.setTitle(Layout.buttonTitle, for: .normal)
        button.layer.cornerRadius = Layout.cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = .white
        button.setTitleColor(.systemGray2, for: .disabled)
        button.setTitleColor(.red, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(noAuthButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.layer.cornerRadius = Layout.cornerRadius
        webView.layer.masksToBounds = true
        webView.navigationDelegate = self
        if let url = URL(string: loginUrl) {
            let request = URLRequest(url: url)
            webView.load(request)
        }

        view.addSubview(webView)
        view.addSubview(noAuthButton)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                            constant: -Layout.buttonHeight*2),

            noAuthButton.topAnchor.constraint(equalTo: webView.bottomAnchor,
                                              constant: Layout.inset),
            noAuthButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noAuthButton.heightAnchor.constraint(equalToConstant: Layout.buttonHeight),
            noAuthButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            noAuthButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        view.backgroundColor = Layout.backgroundcolor
        navigationItem.title = Layout.title

    }
    // MARK: - Private Functions
    
    @objc private func noAuthButtonTapped() {
        loadMainViewController()
    }

    private func loadMainViewController() {
        let viewController = TodoListViewController()
        viewController.auth = authType.rawValue + token
        viewController.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
// MARK: - WKNavigationDelegate

extension AuthViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {

        guard let url = navigationResponse.response.url, url.path == "/verification_code",
              let fragment = url.fragment else {
            decisionHandler(.allow)
            return
        }

        let params = fragment
            .components(separatedBy: "&")
            .map { $0.components(separatedBy: "=") }
            .reduce([String: String]()) { result, param in
                var dict = result
                let key = param[0]
                let value = param[1]
                dict[key] = value
                return dict
            }

        guard let token = params["access_token"] else {
            decisionHandler(.allow)
            return
        }

        decisionHandler(.cancel)

        self.token = token
        self.authType = .yandexOAuth
        self.loadMainViewController()
    }
}
