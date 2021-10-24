//
//  DeviceSettings.swift
//
//  Created by Sándor Németh on 2021.10.13.
//  Copyright © 2021 Sándor Németh. All rights reserved.
//

import UIKit

struct DeviceSettings: Codable {
    var deviceCode: Int64
    var unitNumber: Int64
    var exists: Bool
    var registered: Bool
    var isFahrenheit = false
    var dateFormat: DateFormat
    var dateSeparator: String
    var timeSeparator: String
    var timeFormat: Bool
}

enum DateFormat: String, Codable, CaseIterable {
    case YMD = "YMD"
    case DMY = "DMY"
    case MDY = "MDY"
}
