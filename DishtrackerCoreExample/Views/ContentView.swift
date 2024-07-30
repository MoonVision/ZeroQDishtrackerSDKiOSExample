//
//  ContentView.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2024 Dishtracker GmbH. All rights reserved.
//

import SwiftUI
import Combine
import DishtrackerCore

@MainActor
final class ContentViewModel: ObservableObject {
    private let theme: Theme
    @Published private(set) var text: String = ""

    var settings: DishtrackerSettings {
        DishtrackerSettings(
            authToken: "Bearer xxx",
            theme: self.theme,
            locale: Locale.current,
            isFixedDesk: Platform.isPad
        )
    }

    lazy var dishtracker = Dishtracker(
        application: UIApplication.shared,
        settings: self.settings,
        onCancel: { [weak self] in
            self?.text = "Canceled"
        },
        onError: { [weak self] error in
            self?.text = "Error: \(error.localizedDescription)"
        },
        onCheckoutCompletion: { [weak self] checkoutResult in
            self?.text = checkoutResult.debugDescription
        },
        onLocationCompletion: { [weak self] location in
            self?.location = location
            self?.text = "Location: \(location.name)"
        }
    )

    var location: Location? {
        didSet {
            self.text = "Location: \(self.location?.name ?? "?")"
        }
    }

    init(
        theme: Theme
    ) {
        self.theme = theme

        self.text = "Version: \(self.dishtracker.version)"
    }
}

struct ContentView: View {
    @Environment(\.theme) var theme
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var sceneDelegate: SceneDelegate

    var body: some View {
        VStack {
            VStack {
                Text(self.viewModel.text)

                Spacer()

                Button {
                    self.setupLocation()
                } label: {
                    Text("Setup Location for Test")
                }
                .frame(height: 48)
                .foregroundColor(self.theme.primary.color)

                Button {
                    self.startCheckoutScan()
                } label: {
                    Text("Start Checkout Scan")
                }
                .frame(height: 48)
                .foregroundColor(self.theme.primary.color)

                Button {
                    self.startLocationScan()
                } label: {
                    Text("Start Location Scan")
                }
                .frame(height: 48)
                .foregroundColor(self.theme.primary.color)
            }
            .foregroundColor(.black)
            .edgesIgnoringSafeArea(.all)
            .ignoresSafeArea()
            .background(self.theme.background.color)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // print("onAppear")
        }
        .onDisappear {
            // print("onDisappear")
        }
        .padding(8)
        .foregroundColor(.black)
    }

    private let userSettings = DishtrackerUserSettings(
        userID: UUID().uuidString,
        isAdmin: true
    )

    private func startCheckoutScan() {
        guard let window = self.sceneDelegate.window, let location = self.viewModel.location else {
            self.startLocationScan()
            return
        }

        self.viewModel.dishtracker.startCheckoutScan(
            window: window,
            locationID: location.locationID,
            transactionID: UUID().uuidString,
            userSettings: self.userSettings
        )
    }

    private func startLocationScan() {
        guard let window = self.sceneDelegate.window else {
            return
        }
        self.viewModel.dishtracker.startLocationScan(
            window: window,
            userSettings: self.userSettings
        )
    }

    private func setupLocation() {
        self.viewModel.location = .dishtracker
    }
}
