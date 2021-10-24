//
//  RoomValue.swift
//
//  Created by Sándor Németh on 2021.10.11.
//  Copyright © 2021 Sándor Németh. All rights reserved.
//

import Foundation

struct Indoor: Decodable {
    var humidity: Double?
    var installed: Bool
    var temperature: Double?
    var timestamp: String?
    
}
