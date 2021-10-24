//
//  ErrorView.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 12..
//

import SwiftUI

struct ErrorView: View {
    var error: AppError
    var retryHandler: () -> Void
    var settingsHandler: () -> Void
    
    var body: some View {
        ZStack {
            BackgroundView()
                        
            VStack {
                Text("An Error Occured")
                    .font(.title)
                    .foregroundColor(.white)
                Text(error.message)
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 40).padding()
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 10) {
                HeaderView(title: "ERROR")
                HStack {
                    Button(action: retryHandler, label: {
                        Text("Retry")
                            .bold()
                            .foregroundColor(.white)
                        })
                        .padding(.trailing,50)
                        .font(.title2)
                    
                    Spacer()
                    
                    Button(action: settingsHandler, label: {
                            Text("Settings")
                                .bold()
                                .foregroundColor(.white)
                    }).font(.title2)
                }.padding([.trailing, .leading], 15)
                
                SettingsDevider()
                
                Spacer()
            }
        }
    }
}
