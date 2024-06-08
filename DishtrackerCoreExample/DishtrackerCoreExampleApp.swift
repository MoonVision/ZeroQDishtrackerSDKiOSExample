//
//  DishtrackerCoreExampleApp.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2024 Dishtracker GmbH. All rights reserved.
//

import SwiftUI

@main
struct DishtrackerCoreExampleApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: ContentViewModel(
                    theme: self.delegate.theme
                )
            )
        }
    }
}
