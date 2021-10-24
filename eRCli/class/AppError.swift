//
//  AppError.swift
//
//  Created by Sándor Németh on 2021.10.23.
//  Copyright © 2021 Sándor Németh. All rights reserved.
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
