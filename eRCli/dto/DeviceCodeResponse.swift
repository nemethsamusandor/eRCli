//
//  DeviceCode.swift
//
//  Created by Sándor Németh on 2021.10.11.
//  Copyright © 2021 Sándor Németh. All rights reserved.
//

import Foundation

struct DeviceCodeResponse: Codable {
    var exists: Bool
    var registered: Bool
    var id: String
    var deviceType: Int
}
