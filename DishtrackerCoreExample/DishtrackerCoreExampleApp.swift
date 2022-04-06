//
//  DishtrackerCoreExampleApp.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2022 Dishtracker GmbH. All rights reserved.
//

import SwiftUI
import DishtrackerCore

@main
struct DishtrackerCoreExampleApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: ContentViewModel(
                    theme: self.delegate.theme,
                    location: self.delegate.location,
                    orientationLock: self.delegate
                )
            )
        }
    }
}
