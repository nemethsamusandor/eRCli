//
//  RoomTempRequest.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 11..
//

import Foundation

struct RoomTempRequest {
    let installResourceURL:URL
    let deviceCode: Int64
    let unitNumber: Int64
    let SERVER = "https://deployment.egain.io"
    let API_PATH = "/api"
    let INDOOR_PATH = "/indoor/"
    let INSTALL_PATH = "/installation/device/verify/%d?unit=%d"

    init(deviceCode: Int64, unitNumber: Int64) {
        self.deviceCode = deviceCode
        self.unitNumber = unitNumber
        
        let installResourceString = String(format: SERVER + API_PATH + INSTALL_PATH, deviceCode, unitNumber)
        
        guard let installResourceURL = URL(string: installResourceString) else {fatalError()}
        
        self.installResourceURL = installResourceURL
    }
    
    func installDevice (completion: @escaping(Result<DeviceCodeResponse, AppError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: installResourceURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(AppError(code: .noDataAvailable, message: "No data received from the interface: " + installResourceURL.absoluteString)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let deviceCodeResponse = try decoder.decode(DeviceCodeResponse.self, from: jsonData)

                Session().deviceSettings.exists = deviceCodeResponse.exists
                Session().deviceSettings.registered = deviceCodeResponse.registered
                
                if deviceCodeResponse.exists && deviceCodeResponse.registered {
                    completion(.success(deviceCodeResponse))
                }
                else {
                    completion(.failure(AppError(code: .wrongSettings, message: "Device code: \(deviceCode) or unit number: \(unitNumber) is misconfigured!")))
                }
            } catch {
                completion(.failure(AppError(code: .canNotProcessData, message: "Data cannot be processed")))
            }
        }
        dataTask.resume()
    }
    
    func getTemperature (deviceId: String, completion: @escaping(Result<Indoor, AppError>) -> Void) {
        let indoorResourceString = SERVER + API_PATH + INDOOR_PATH + deviceId
        
        guard let indoorResourceURL = URL(string: indoorResourceString) else {fatalError()}
        
        let dataTask = URLSession.shared.dataTask(with: indoorResourceURL) { data, _, _ in
            guard let jsonData = data else {
                completion(.failure(AppError(code: .noDataAvailable, message: "No data received from the interface: " + indoorResourceURL.absoluteString)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let indoor = try decoder.decode(Indoor.self, from: jsonData)
                completion(.success(indoor))
            } catch {
                completion(.failure(AppError(code: .canNotProcessData, message: "Data cannot be processed")))
            }
        }
        dataTask.resume()
    }
}
