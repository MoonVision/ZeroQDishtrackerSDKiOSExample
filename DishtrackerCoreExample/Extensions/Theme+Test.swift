//
//  Theme+Test.swift
//  DishtrackerCoreExample
//
//  Created by Stefan Fessler on 04.04.22.
//

import Foundation
import DishtrackerCore
import UIKit

extension Theme {
    static let test = Theme(
        primary: .magenta,
        secondary: .yellow,
        disabled: .magenta.withAlphaComponent(0.5),
        success: .green,
        info: .blue,
        warning: .orange,
        danger: .red,
        background: .systemBackground
    )
}
