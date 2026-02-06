//
//  Location+Test.swift
//  DishtrackerCore
//
//  Created by Stefan Fessler on 06.04.22.
//  Copyright © 2024 Dishtracker GmbH. All rights reserved.
//

import Foundation
import DishtrackerCore

extension Location {
    static let dishtracker = Location(
        locationID: "locationID",
        name: "Demo"
    )

    static let hellotessDev = Location(
        locationID: "hellotess-dev",
        name: "HelloTess Dev"
    )

    static let hellotessDevFeature = Location(
        locationID: "hellotess-dev-feature",
        name: "HelloTess Dev Feature"
    )

    static let dishtrackerCloudDemo = Location(
        locationID: "dishtracker-cloud-demo",
        name: "Dishtracker Cloud Demo"
    )

    static let dishtrackerCloudDemoMobile = Location(
        locationID: "dishtracker-cloud-demo-mobile",
        name: "Dishtracker Cloud Demo Mobile"
    )
}

extension String {
    static let authDev = "Bearer xxx"

    static let authCloud = "Bearer xxx"
}
