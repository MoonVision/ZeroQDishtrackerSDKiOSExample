//
//  AppDelegate.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2022 Dishtracker GmbH. All rights reserved.
//

import Foundation
import DishtrackerCore
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject, OrientationLockProtocol {
    var orientationLock: UIInterfaceOrientationMask = .all
    let location = Location.test // TODO: Location
    let theme = Theme.test // TODO: Theme

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // TODO: OrientationLock
        OrientationHelper.shared.update(orientationLocker: self)

        // TODO: Appearance
        Appearance.applyAppearance(tintColor: self.theme.primary)

        let font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle(rawValue: "HelveticaNeue"))
        UILabel.appearance().font = font
        UITextView.appearance().font = font
        UITextField.appearance().font = font

        return true
    }

    // TODO: OrientationLock
    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor
        window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}
