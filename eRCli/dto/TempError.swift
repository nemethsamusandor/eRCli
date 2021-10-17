//
//  TempError.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 12..
//

import Foundation

enum RoomTempError: Error {
    case noDataAvailable(String)
    case canNotProcessData(String)
    case wrongDeviceCode(String)
    case wrongSettings(String)
    case scanError(String)
    case qrCodeNotValid(String)
}
