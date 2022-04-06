//
//  SceneDelegate.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2022 Dishtracker GmbH. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import DishtrackerCore

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
        let window = UIWindow(windowScene: scene)
        self.window = window
    }
}
