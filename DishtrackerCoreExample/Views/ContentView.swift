//
//  ContentView.swift
//  Dishtracker
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

    @Published var isAdmin = false
    @Published var isEndlessLoop = false
    @Published var isQualified = false
    @Published var isFixedDesk = false
    @Published var isAutodetectOn = false
    @Published var startWithEBon = false
    @Published var useMockAPI = false

    init(theme: Theme) {
        self.theme = theme
        #if DEBUG
        self.location = .hellotessDev
        #endif
        self.text = "SDK BundleVersion: \(Dishtracker.bundleVersion)"

        #if DEBUG
        self.isFixedDesk = false
        self.useMockAPI = true
        #else
        self.isFixedDesk = UIDevice.isPad
        #endif
    }

    private func authThoken() -> String {
        if let location, location.locationID.contains("dev") {
            return .authDev
        } else {
            return .authCloud
        }
    }

    private func settings() -> DishtrackerSettings {
        DishtrackerSettings(
            authToken: self.authThoken(),
            theme: self.theme,
            locale: Locale.current,
            isFixedDesk: self.isFixedDesk,
            isAutodetectOn: self.isAutodetectOn
        )
    }

    func userSettings() -> DishtrackerUserSettings {
        DishtrackerUserSettings.mock(
            isAdmin: self.isAdmin
        )
    }

    func checkoutSettings() -> DishtrackerCheckoutSettings {
        DishtrackerCheckoutSettings(
            isQualified: self.isQualified,
            isEndlessLoop: self.isEndlessLoop,
            scanSettings: DishtrackerCheckoutScanSettings.mock(),
            eBonSettings: self.startWithEBon ? DishtrackerCheckoutEBonSettings.mock() : nil
        )
    }

    private(set) lazy var dishtracker: Dishtracker = {
        Dishtracker(
            application: UIApplication.shared,
            settings: self.settings(),
            onCancel: { [weak self] in
                self?.text = "Canceled"
            },
            onError: { [weak self] error in
                self?.text = "Error: \(error.localizedDescription)"
            },
            onCheckoutCompletion: { [weak self] checkoutResult in
                self?.text = checkoutResult.debugDescription
            },
            onCheckoutButtonCompletion: { type, index in
                print("Button pressed with type: \(type) at index: \(index)")
            },
            onLocationCompletion: { [weak self] location in
                guard let self else { return }
                self.setLocation(
                    location: location
                )
            }
        )
    }()

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
}

@available(iOS 16.0, *)
@MainActor
struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var sceneDelegate: SceneDelegate

    @State private var settingsDetent: PresentationDetent = UIDevice.isPad ? .large : .medium
    @State private var showingSettings = false

    @State private var showingLocationSetup = false

    var body: some View {
        VStack(alignment: .center, spacing: 8.0 * .dishtrackerScale2) {
            VStack(alignment: .center, spacing: 8.0 * .dishtrackerScale2) {
                Section {
                    VStack(alignment: .leading, spacing: 8.0 * .dishtrackerScale2) {
                        Section {
                            Text(self.viewModel.text)
                                .font(.body)
                                .multilineTextAlignment(.leading)
                                .textSelection(.enabled)
                        }
                    }
                }

                Spacer()

                Section {
                    VStack(alignment: .center, spacing: 8.0 * .dishtrackerScale2) {
                        if self.viewModel.location != nil {
                            DishtrackerButtonView(
                                model: DishtrackerButtonViewModel(
                                    title: R.string.localizable.startCheckoutScan(),
                                    style: .primary,
                                    minWidth: .buttonWidth * 1.4,
                                    tintColor: self.viewModel.theme.primary,
                                    action: {
                                        self.startCheckoutScan()
                                    }
                                )
                            )
                        }

                        DishtrackerButtonView(
                            model: DishtrackerButtonViewModel(
                                title: R.string.localizable.settings(),
                                style: .secondary,
                                minWidth: .buttonWidth * 1.4,
                                tintColor: self.viewModel.theme.primary,
                                action: {
                                    self.showingSettings = true
                                }
                            )
                        )
                        .sheet(isPresented: self.$showingSettings) {
                            SettingsView(viewModel: self.viewModel)
                                .presentationDetents(
                                    [.medium, .large],
                                    selection: self.$settingsDetent
                                 )
                        }

                        DishtrackerButtonView(
                            model: DishtrackerButtonViewModel(
                                title: R.string.localizable.setupLocation(),
                                style: .secondary,
                                minWidth: .buttonWidth * 1.4,
                                tintColor: self.viewModel.theme.primary,
                                action: {
                                    self.showingLocationSetup = true
                                }
                            )
                        )
                        .actionSheet(isPresented: self.$showingLocationSetup) {
                            let locations: [Location] = [
                                .hellotessDev,
                                .hellotessDevFeature,
                                .dishtrackerCloudDemo,
                                .dishtrackerCloudDemoMobile
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
                                .default(
                                    Text(
                                        R.string.localizable.startLocationScan()
                                    )
                                ) {
                                    self.startLocationScan()
                                }
                            )

                            return ActionSheet(
                                title: Text(
                                    R.string.localizable.setupLocation()
                                ),
                                message: Text(
                                    R.string.localizable.chooseOne()
                                ),
                                buttons: buttons
                            )
                        }
                    }
                }
            }
            .padding(8 * .dishtrackerScale2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if self.viewModel.location == nil {
                self.showingLocationSetup = true
            }
        }
        .foregroundColor(.black)
        .background(self.viewModel.theme.background.color)
    }

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
            userSettings: self.viewModel.userSettings(),
            checkoutSettings: self.viewModel.checkoutSettings(),
            useMockAPI: self.viewModel.useMockAPI
        )
    }

    private func startLocationScan() {
        guard let window = self.sceneDelegate.window else {
            return
        }
        self.viewModel.dishtracker.startLocationScan(
            window: window,
            userSettings: self.viewModel.userSettings()
        )
    }
}

@MainActor
struct SettingsView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0 * .dishtrackerScale2) {
            Text("SDK Settings")
                .foregroundStyle(self.viewModel.theme.primary.color)
                .font(.dishtrackerText)
            Toggle(
                "FixedDesk",
                isOn: Binding(
                    get: {
                        self.viewModel.isFixedDesk
                    },
                    set: { newValue in
                        self.viewModel.isFixedDesk = newValue
                        if !newValue {
                            self.viewModel.startWithEBon = false
                        }
                    }
                )
            )
            Toggle(
                "Admin",
                isOn: Binding(
                    get: {
                        self.viewModel.isAdmin
                    },
                    set: { newValue in
                        self.viewModel.isAdmin = newValue
                    }
                )
            )
            Toggle(
                "Qualified",
                isOn:
                    Binding(
                        get: {
                            self.viewModel.isQualified
                        },
                        set: { newValue in
                            self.viewModel.isQualified = newValue
                        }
                    )
            )
            Toggle(
                "EndlessLoop (skip onCheckoutCompletion)",
                isOn: Binding(
                    get: {
                        self.viewModel.isEndlessLoop
                    },
                    set: { newValue in
                        self.viewModel.isEndlessLoop = newValue
                    }
                )
            )
            Toggle(
                "Autodetect",
                isOn: Binding(
                    get: {
                        self.viewModel.isAutodetectOn
                    },
                    set: { newValue in
                        self.viewModel.isAutodetectOn = newValue
                    }
                )
            )
            .disabled(true)
            Text("Demo Settings")
                .foregroundStyle(self.viewModel.theme.primary.color)
                .font(.dishtrackerText)
            Toggle(
                "MockAPI",
                isOn: Binding(
                    get: {
                        self.viewModel.useMockAPI
                    },
                    set: { newValue in
                        self.viewModel.useMockAPI = newValue
                    }
                )
            )
            Toggle(
                "StartWithEBon",
                isOn: Binding(
                    get: {
                        self.viewModel.startWithEBon
                    },
                    set: { newValue in
                        self.viewModel.startWithEBon = newValue
                    }
                )
            )
            .disabled(!self.viewModel.isFixedDesk)
        }
        .padding(32 * .dishtrackerScale2)
        .tint(self.viewModel.theme.primary.color)
    }
}
