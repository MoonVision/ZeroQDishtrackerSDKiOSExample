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
    let theme: Theme
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
            guard let self else { return }
            self.setLocation(
                location: location
            )
        }
    )

    private(set) var location: Location? {
        didSet {
            self.setLocationText()
        }
    }

    private func setLocationText() {
        self.text = "Location: \(self.location?.name ?? "?")\nConfigName: \(self.location?.configName ?? "default")\nBaseURL: \(self.location?.baseURL?.absoluteString ?? "default")"
    }

    func setLocation(
        location: Location
    ) {
        self.location = location
    }

    init(
        theme: Theme
    ) {
        self.theme = theme
        self.text = "SDK BundleVersion: \(self.dishtracker.bundleVersion)"
    }
}

@MainActor
struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var sceneDelegate: SceneDelegate

    @State private var showingSetupAlert = false

    var body: some View {
        VStack {
            VStack {
                Text(self.viewModel.text)
                    .textSelection(.enabled)

                Spacer()

                if let location = self.viewModel.location {
                    Button {
                        self.startCheckoutScan()
                    } label: {
                        Text("Start Checkout Scan")
                    }
                    .frame(height: 48)
                    .foregroundColor(self.viewModel.theme.primary.color)
                }

                Button {
                    self.showingSetupAlert = true
                } label: {
                    Text("Setup Location")
                }
                .frame(height: 48)
                .foregroundColor(self.viewModel.theme.secondary.color)
                .actionSheet(isPresented: self.$showingSetupAlert) {
                    let locations: [Location] = [
                    ]

                    var buttons: [ActionSheet.Button] = locations.map({ location in
                        .default(Text(location.info)) {
                            self.viewModel.setLocation(
                                location: location
                            )
                        }
                    })
                    buttons.append(.cancel())
                    buttons.append(
                        .default(Text("Start Location Scan")) {
                            self.startLocationScan()
                        }
                    )

                    return ActionSheet(
                        title: Text("Setup Location"),
                        message: Text("Choose one of those:"),
                        buttons: buttons
                    )
                }
            }
            .padding(.top, 64)
            .padding(.bottom, 32)
            .padding(.horizontal, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            // print("onAppear")
            if self.viewModel.location == nil {
                self.showingSetupAlert = true
            }
        }
        .onDisappear {
            // print("onDisappear")
        }
        .foregroundColor(.black)
        .edgesIgnoringSafeArea(.all)
        .ignoresSafeArea()
        .background(self.viewModel.theme.background.color)
    }

    private let userSettings = DishtrackerUserSettings(
        userID: UUID().uuidString,
        isAdmin: true
    )

    private func startCheckoutScan() {
        guard let window = self.sceneDelegate.window,
              let location = self.viewModel.location
        else {
            self.startLocationScan()
            return
        }

        self.viewModel.dishtracker.startCheckoutScan(
            window: window,
            location: location,
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
}
