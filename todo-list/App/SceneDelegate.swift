//
//  SceneDelegate.swift
//  todo-list
//
//  Created by Алексей Поляков on 30.07.2022.
//

import UIKit
import CocoaLumberjack

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        dynamicLogLevel = DDLogLevel.verbose
        DDLog.add(DDOSLogger.sharedInstance)

        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)

        let viewController = AuthViewController()

        window?.rootViewController = UINavigationController(rootViewController: viewController)
        window?.makeKeyAndVisible()
    }
}
