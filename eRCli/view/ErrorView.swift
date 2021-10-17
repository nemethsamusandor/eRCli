//
//  ErrorView.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 12..
//

import SwiftUI

struct ErrorView: View {
    var error: RoomTempError
    var retryHandler: () -> Void
    var settingsHandler: () -> Void
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                Text("An Error Occured")
                    .font(.title)
                    .foregroundColor(.white)
                Text(getErrorMessage())
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40).padding()
                    .foregroundColor(.white)
                HStack {
                    Button(action: retryHandler,
                           label: { Text("Retry").bold() })
                        .padding(.trailing,50)
                        .font(.title2)
                    Button(action: settingsHandler,
                           label: { Text("Settings").bold() })
                        .font(.title2)
                }
            }
            
            VStack(spacing: 10) {
                HeaderView(title: "ERROR")
                Spacer()
            }
        }
    }
    
    func getErrorMessage() -> String {
        switch error {
            case .canNotProcessData(let message):
                return message
            case .noDataAvailable(let message):
                return message
            case .wrongDeviceCode(let message):
                return message
            case .wrongSettings(let message):
                return message
            case .scanError(let message):
                return message
            case .qrCodeNotValid(let message):
                return message
        }
    }
}
