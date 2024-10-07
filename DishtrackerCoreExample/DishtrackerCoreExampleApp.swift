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
            if #available(iOS 16.0, *) {
                ContentView(
                    viewModel: ContentViewModel(
                        theme: self.delegate.theme
                    )
                )
            } else {
                EmptyView()
            }
        }
    }
}
