//
//  ContentView.swift
//  Dishtracker
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2024 Dishtracker GmbH. All rights reserved.
//

import SwiftUI
import Combine
import Rswift
import DishtrackerCore

@MainActor
final class ContentViewModel: ObservableObject {
    let theme: Theme
    @Published private(set) var text: String = ""

    @Published var isAdmin = false
    @Published var isEndlessLoop = false
    @Published var isQualified = false
    @Published var isFixedDesk = false
    @Published var isDevMode = false
    @Published var showScanInfoAlways = false
    @Published var startWithEBon = false
    @Published var useMockAPI = false
    @Published var isAutodetectOn = false

    init(theme: Theme) {
        self.theme = theme
        self.text = "SDK BundleVersion: \(Dishtracker.bundleVersion)"
        self.isFixedDesk = UIDevice.isPad
        #if DEBUG
        self.location = .hellotessDev
        self.useMockAPI = Platform.isDebug
        #endif
        self.createOrUpdateDishtracker()
    }

    private var authThoken: String {
        if let location, location.locationID.contains("dev") {
            return .authDev
        } else {
            return .authCloud
        }
    }

    private func settings() -> DishtrackerSettings {
        DishtrackerSettings(
            authToken: self.authThoken,
            theme: self.theme,
            locale: Locale.current,
            isFixedDesk: self.isFixedDesk,
            isDevMode: self.isDevMode,
            isAutodetectOn: self.isAutodetectOn
        )
    }

    func userSettings() -> DishtrackerUserSettings {
        DishtrackerUserSettings(
            userID: UUID().uuidString,
            isAdmin: self.isAdmin
        )
    }

    func checkoutSettings() -> DishtrackerCheckoutSettings {
        DishtrackerCheckoutSettings(
            isQualified: self.isQualified,
            isEndlessLoop: self.isEndlessLoop,
            showScanInfoAlways: self.showScanInfoAlways,
            scanSettings: DishtrackerCheckoutScanSettings(),
            eBonSettings: self.startWithEBon ? DishtrackerCheckoutEBonSettings(
                image: UIImage.generateQRCode(from: UUID().uuidString)!,
                buttonTitles: [
                    R.string.localizable.printReceipt(
                        preferredLanguages: []
                    )
                ],
                dismissAfter: 10.0,
                expiresAfter: 30.0
            ) : nil
        )
    }

    private func createOrUpdateDishtracker() {
        self.dishtracker = Dishtracker(
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
            onCheckoutButtonCompletion: { checkoutButtonResult in
                print("Button pressed with type: \(checkoutButtonResult.type) at index: \(checkoutButtonResult.index)")
            },
            onLocationCompletion: { [weak self] location in
                guard let self else { return }
                self.setLocation(
                    location: location
                )
            }
        )
    }
    private(set) var dishtracker: Dishtracker?

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

    func startCheckoutScan(
        window: UIWindow,
        location: Location,
        transactionID: String
    ) {
        self.createOrUpdateDishtracker()
        self.dishtracker?.startCheckoutScan(
            window: window,
            location: location,
            transactionID: transactionID,
            userSettings: self.userSettings(),
            checkoutSettings: self.checkoutSettings(),
            useMockAPI: self.useMockAPI
        )
    }

    func startLocationScan(
        window: UIWindow
    ) {
        self.createOrUpdateDishtracker()
        self.dishtracker?.startLocationScan(
            window: window,
            userSettings: self.userSettings()
        )
    }
}

@available(iOS 17.0, *)
@MainActor
struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var sceneDelegate: SceneDelegate

    @State private var settingsDetent: PresentationDetent = .large
    @State private var showingSettings = false
    @State private var showingLocationSetup = false

    @State private var size: CGSize = .zero

    var body: some View {
        VStack(alignment: .center, spacing: 8.0 * .dishtrackerScale18) {
            VStack(alignment: .center, spacing: 8.0 * .dishtrackerScale18) {
                Image(
                    "DT_Logo_RGB_K",
                    bundle: Bundle(for: Dishtracker.self)
                )
                .resizable()
                .frame(
                    width: 224 * .dishtrackerScale18,
                    height: 60 * .dishtrackerScale18
                )
                .padding(.bottom, 16)

                Section {
                    VStack(alignment: .leading, spacing: 8.0 * .dishtrackerScale18) {
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
                    VStack(alignment: .center, spacing: 8.0 * .dishtrackerScale18) {
                        if self.viewModel.location != nil {
                            DishtrackerButtonView(
                                model: DishtrackerButtonViewModel(
                                    title: R.string.localizable.startCheckoutScan(),
                                    style: .primary,
                                    minWidth: UIDevice.isPad ? .buttonWidth * 1.4 : self.size.width - 16,
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
                                minWidth: UIDevice.isPad ? .buttonWidth * 1.4 : self.size.width - 16,
                                tintColor: self.viewModel.theme.primary,
                                action: {
                                    self.showingSettings = true
                                }
                            )
                        )
                        .sheet(isPresented: self.$showingSettings) {
                            SettingsView(viewModel: self.viewModel)
                                .presentationDetents(
                                    [.large],
                                    selection: self.$settingsDetent
                                )
                        }

                        DishtrackerButtonView(
                            model: DishtrackerButtonViewModel(
                                title: R.string.localizable.setupLocation(),
                                style: .secondary,
                                minWidth: UIDevice.isPad ? .buttonWidth * 1.4 : self.size.width - 16,
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
                                    R.string.localizable.pleaseSelectOne()
                                ),
                                buttons: buttons
                            )
                        }
                    }
                }
            }
            .padding(8 * .dishtrackerScale18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if self.viewModel.location == nil {
                self.showingLocationSetup = true
            }
        }
        .onGeometryChange(for: CGSize.self) { geometry in
            geometry.size
        } action: {
            self.size = $0
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

        self.viewModel.startCheckoutScan(
            window: window,
            location: location,
            transactionID: UUID().uuidString
        )
    }

    private func startLocationScan() {
        guard let window = self.sceneDelegate.window else {
            return
        }
        self.viewModel.startLocationScan(
            window: window
        )
    }
}

@MainActor
struct SettingsView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8.0 * .dishtrackerScale18) {
            Text("SDK Settings")
                .foregroundStyle(self.viewModel.theme.primary.color)
                .font(.dishtrackerText)
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
            Toggle(
                "Admin",
                isOn: Binding(
                    get: {
                        self.viewModel.isAdmin
                    },
                    set: { newValue in
                        self.viewModel.isAdmin = newValue
                        if !newValue {
                            self.viewModel.isDevMode = false
                        }
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
                "FixedDesk (iPad only)",
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
            .disabled(!UIDevice.isPad)
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
                "ShowScanInfoAlways",
                isOn: Binding(
                    get: {
                        self.viewModel.showScanInfoAlways
                    },
                    set: { newValue in
                        self.viewModel.showScanInfoAlways = newValue
                    }
                )
            )
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
                "DevMode",
                isOn: Binding(
                    get: {
                        self.viewModel.isDevMode
                    },
                    set: { newValue in
                        self.viewModel.isDevMode = newValue
                    }
                )
            )
            .disabled(!self.viewModel.isAdmin)
            Toggle(
                "StartWithEBon (FixedDesk only)",
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
        .padding(32 * .dishtrackerScale18)
        .tint(self.viewModel.theme.primary.color)
    }
}
