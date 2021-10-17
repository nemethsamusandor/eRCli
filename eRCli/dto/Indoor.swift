//
//  RoomValue.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 11..
//

import Foundation

struct Indoor: Decodable {
    var humidity: Double?
    var installed: Bool
    var temperature: Double?
    var timestamp: String?
    
}
