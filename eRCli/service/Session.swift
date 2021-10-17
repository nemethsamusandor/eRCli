//
//  Session.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 14..
//

import UIKit

class Session: ObservableObject {
    var deviceSettings: DeviceSettings {
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                let defaults = UserDefaults.standard
                 defaults.set(encoded, forKey: "deviceSettings")
            }
        }
        get {
            if let savedDeviceSettings = UserDefaults.standard.object(forKey: "deviceSettings") as? Data,
                let loadedDeviceSettings = try? JSONDecoder().decode(DeviceSettings.self, from: savedDeviceSettings) {
                    return loadedDeviceSettings
                }
            return DeviceSettings(deviceCode: -1, unitNumber: 5, exists: false, registered: false, isFahrenheit: false,
                                  dateFormat: .YMD, dateSeparator: "-", timeSeparator: ":", timeFormat: true)
        }   
    }
}
