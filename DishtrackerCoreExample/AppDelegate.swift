//
//  AppDelegate.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2024 Dishtracker GmbH. All rights reserved.
//

import Foundation
import DishtrackerCore
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    let theme = Theme.dishtracker

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        Appearance.applyAppearance(
            theme: self.theme
        )

        return true
    }

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor
        window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        .all
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(
            name: nil,
            sessionRole: connectingSceneSession.role
        )
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}
