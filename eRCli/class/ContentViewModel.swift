//
//  ContentViewModel.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 12..
//

import UIKit

class ContentViewModel: ObservableObject {
    enum State {
        case idle
        case loading
        case settings
        case loaded(Indoor)
        case failed(AppError)
        case scanQR
        case setCode(Int64?)
    }
    
    @Published private(set) var state = State.idle
        
    private var deviceSettings: DeviceSettings
    private var roomTempRequest: RoomTempRequest

    init() {
        self.deviceSettings = Session().deviceSettings
        self.roomTempRequest = RoomTempRequest(deviceCode: -1, unitNumber: 5)
    }

    func check() {
        self.deviceSettings = Session().deviceSettings

        if deviceSettings.deviceCode < 0 {
            self.state = .settings
        }
        else {
            initialize()
        }
    }
    
    func error(error: AppError) {
        self.state = .failed(error)
    }
        
    func settings() {
        self.state = .settings
    }
    
    func scanQR() {
        self.state = .scanQR
    }
    
    func setCode(code: Int64?) {
        self.state = .setCode(code)
    }
    
    private func initialize() {
        state = .loading

        roomTempRequest = RoomTempRequest(deviceCode: deviceSettings.deviceCode, unitNumber: deviceSettings.unitNumber)
        
        roomTempRequest.installDevice { [self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self.state = .failed(error)
                case .success(let deviceCode):
                    getTemperature(deviceCode: deviceCode)
                }
            }
        }
    }
    
    private func getTemperature(deviceCode: DeviceCodeResponse) {
        roomTempRequest.getTemperature(deviceId: deviceCode.id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    self?.state = .failed(error)
                case .success(let indoor):
                    self?.state = .loaded(indoor)
                }
            }
        }
    }
}
