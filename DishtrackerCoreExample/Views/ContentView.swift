//
//  ContentView.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 24.03.22.
//  Copyright © 2022 Dishtracker GmbH. All rights reserved.
//

import SwiftUI
import Combine
import DishtrackerCore

class ContentViewModel: ObservableObject {
    let location: Location
    let theme: Theme
    private var orientationLock: OrientationLockProtocol
    @Published private(set) var text: String = ""

    init(
        theme: Theme,
        location: Location,
        orientationLock: OrientationLockProtocol
    ) {
        self.theme = theme
        self.location = location
        self.orientationLock = orientationLock
    }

    lazy var dishtracker = Dishtracker(
        location: self.location,
        application: UIApplication.shared,
        theme: self.theme,
        delegateCheckout: self,
        onCompletion: { [weak self] checkoutItems in
            guard let self = self else {
                return
            }
            self.text = checkoutItems.info
        },
        onCancel: { [weak self] in
            guard let self = self else {
                return
            }
            self.text = "Cancel"
        },
        onError: { [weak self] error in
            guard let self = self else {
                return
            }
            self.text = error.localizedDescription
        }
    )
}

extension ContentViewModel: ShowCheckoutViewControllerProtocol {
    func showCheckoutViewController(
        checkoutItems: [CheckoutItem],
        image: UIImage,
        location: Location
    ) {
        print("CheckoutItems: \(checkoutItems.description)")
        print("Image: \(image)")
        print("Location: \(location)")
    }

    func cancel() {
        print("Cancel")
    }
}

struct ContentView: View {
    @ObservedObject internal var viewModel: ContentViewModel
    @EnvironmentObject var sceneDelegate: SceneDelegate
    // @EnvironmentObject var appDelegate: AppDelegate

    var body: some View {
        VStack {
            Text(self.viewModel.text)
                .padding()

            Spacer()

            Button {
                self.start()
            } label: {
                Text("Start")
            }
        }.onAppear {
            // print("onAppear")
        }.onDisappear {
            // print("onDisappear")
        }.padding(16).padding(.bottom, 64)
        .accentColor(self.viewModel.theme.primary.color)
    }

    private func start() {
        self.viewModel.dishtracker.start(
            window: self.sceneDelegate.window!
        )
    }
}
