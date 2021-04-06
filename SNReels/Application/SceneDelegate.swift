//
//  SceneDelegate.swift
//  SNReels
//
//  Created by Sanjeeb on 05/04/21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        VideoCacheManager.shared.clearCache { (mb) in
            print("\(mb) of cache cleared.")
        }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = FeedViewController()
        window?.makeKeyAndVisible()
    }

}

