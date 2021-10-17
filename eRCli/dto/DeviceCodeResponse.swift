//
//  DeviceCode.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 11..
//

import Foundation

struct DeviceCodeResponse: Codable {
    var exists: Bool
    var registered: Bool
    var id: String
    var deviceType: Int
}
