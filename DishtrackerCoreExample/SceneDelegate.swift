//
//  SceneDelegate.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2024 Dishtracker GmbH. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let windowScene = scene as? UIWindowScene {
            self.setupKeyWindow(in: windowScene)
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
      
    }

    func sceneDidBecomeActive(_ scene: UIScene) {

    }

    func sceneWillResignActive(_ scene: UIScene) {

    }

    private func setupKeyWindow(in scene: UIWindowScene) {
        self.window = UIWindow(windowScene: scene)
    }
}
