//
//  SettingsView.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 12..
//
import CodeScanner

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var session = Session()
    @ObservedObject var viewModel: ContentViewModel
    @ObservedObject var deviceCode = NumbersOnly()
    @ObservedObject var unitNumber = NumbersOnly()
    @ObservedObject var timeSeparator = TextLimiter()
    @ObservedObject var dateSeparator = TextLimiter()
    
    @State var temperatureUnitIndex = (Session().deviceSettings.isFahrenheit) ? 1 : 0
    @State var is24 = Session().deviceSettings.timeFormat
    @State var isShowingScanner = false

    init(viewModel: ContentViewModel) {
        self.viewModel = viewModel
        
        deviceCode.value = "\(session.deviceSettings.deviceCode)"
        unitNumber.value = "\(session.deviceSettings.unitNumber)"
        timeSeparator.value = session.deviceSettings.timeSeparator
        dateSeparator.value = session.deviceSettings.dateSeparator
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundView()
            VStack(spacing: 10){
                HeaderView(title: "SETTINGS")

                HStack {
                    Spacer()
                    Button(action: updateSettings,
                        label: { Text("Save").bold() })
                        .font(.title2)
                        .foregroundColor(.white)
                }.padding(.trailing, 15)
                
                VStack {
                    SettingsDevider()
                    /**
                     Device code section
                     */
                    VStack {
                        HStack {
                            Text("Device code:")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 130, alignment: .leading)
                            TextField("Device code",
                                      text: $deviceCode.value)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Image(systemName: "qrcode.viewfinder")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    viewModel.scanQR()
                                }
                            }.padding([.leading, .trailing], 15)
                        
                        SettingsDevider()

                        /**
                         Unit number section
                         */
                        HStack {
                            Text("Unit number:")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 130, alignment: .leading)
                            TextField("Unit number",
                                  text: $unitNumber.value)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }.padding([.leading, .trailing], 15)

                        SettingsDevider()

                        /**
                         Temperature unit selector section
                         */
                        HStack {
                            Text("Temp unit:")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 130, alignment: .leading)
                            Picker("Temperature unit", selection: $temperatureUnitIndex) {
                                Text("Celsius").tag(0)
                                Text("Fahrenheit").tag(1)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Spacer()
                        }.padding([.leading, .trailing], 15)
               
                        SettingsDevider()
                    
                        /**
                         Date format selector section
                         */
                        HStack {
                            Text("Date format:")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 130, alignment: .leading)
                            Picker("Date format", selection: $session.deviceSettings.dateFormat) {
                                ForEach (DateFormat.allCases, id: \.self) {
                                    Text($0.rawValue)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Spacer()
                        }.padding([.leading, .trailing], 15)
                     
                        SettingsDevider()
                    
                        HStack {
                            /**
                             Date separator section
                             */
                            Text("Date separator:")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 130, alignment: .leading)
                            TextField("",
                                      text: $dateSeparator.value)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            /**
                             Time separator
                             */
                            Text("Time separator:")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(width: 130, alignment: .leading)
                            TextField("",
                                      text: $timeSeparator.value)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }.padding([.leading, .trailing], 15)
                     
                        SettingsDevider()
                    }
                    
                    VStack {
                        /**
                         Time format selector section
                         */
                        Toggle(isOn: $is24, label: {
                            Text("24-hour time:")
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                .foregroundColor(.white)
                                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, 0)
                                .frame(alignment: .leading)
                        }).padding([.leading, .trailing], 15)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        
                        SettingsDevider()
                    }
                }.background(Color.blue.opacity(0.2))
                                
//                Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width:60, height: 60)
//                    .foregroundColor(.white)
//                    .onTapGesture {
//                        updateSettings()
//                    }
                Spacer()
            }
        }
    }

    func updateSettings() {
        session.deviceSettings.deviceCode = Int64(deviceCode.value) ?? -1
        session.deviceSettings.unitNumber = Int64(unitNumber.value) ?? 5
        session.deviceSettings.isFahrenheit = temperatureUnitIndex == 1
        session.deviceSettings.dateSeparator = dateSeparator.value
        session.deviceSettings.timeSeparator = timeSeparator.value
        session.deviceSettings.timeFormat = is24
        
        viewModel.check()
    }

}

struct SettingsDevider : View {
    
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color.white)
    }
}

class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
    }
}

class TextLimiter: ObservableObject {
    private let limit: Int
    
    init() {
        self.limit = 1
    }
    
    init(limit: Int) {
        self.limit = limit
    }

    @Published var value: String = "" {
        didSet {
            if value.count > self.limit {
                value = String(value.prefix(self.limit))
            }
        }
    }
}
