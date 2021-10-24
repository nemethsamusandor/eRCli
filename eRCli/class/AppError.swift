//
//  AppError.swift
//  eRCli
//
//  Created by Németh Sándor on 2021. 10. 23..
//

import UIKit

class AppError: Error {
    public let message: String
    public let code: RoomTempError
    
    init(code: RoomTempError, message: String) {
        self.code = code
        self.message = message
    }
}

enum RoomTempError {
    case noDataAvailable
    case canNotProcessData
    case wrongDeviceCode
    case wrongSettings
    case scanError
    case qrCodeNotValid
}
