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
    @ObservedObject private(set) var viewModel: ContentViewModel
    @ObservedObject var deviceCode = NumbersOnly()
    @ObservedObject var unitNumber = NumbersOnly()
    @ObservedObject var timeSeparator = TextLimiter()
    @ObservedObject var dateSeparator = TextLimiter()
    
    @State var temperatureUnitIndex = (Session().deviceSettings.isFahrenheit) ? 1 : 0
    @State var is24 = Session().deviceSettings.timeFormat
    @State var dateFormat = Session().deviceSettings.dateFormat
    @State var isShowingScanner = false
    @State var isChanged = false

    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    init(viewModel: ContentViewModel) {
        self.init(viewModel: viewModel, code: nil)
    }
    
    init(viewModel: ContentViewModel, code: Int64?) {
        self.viewModel = viewModel
        
        self.deviceCode.value = "\(code ?? session.deviceSettings.deviceCode)"
        
        self.unitNumber.value = "\(session.deviceSettings.unitNumber)"
        self.timeSeparator.value = session.deviceSettings.timeSeparator
        self.dateSeparator.value = session.deviceSettings.dateSeparator
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            BackgroundView()
            VStack(spacing: 10){
                HeaderView(title: "SETTINGS")

                HStack {
                    Button(action: checkChanges,
                        label: { Text("Cancel").bold() })
                        .font(.title2)
                        .foregroundColor(.white)
                        .alert(isPresented: $isChanged) {
                            SettingsAlert(leaveAction: viewModel.check, saveAction: updateSettings).showAlert()
                        }

                    Spacer()

                    Button(action: updateSettings,
                        label: { Text("Save").bold() })
                        .font(.title2)
                        .foregroundColor(.white)
                }.padding([.trailing, .leading], 15)
                
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
                            Picker("Date format", selection: $dateFormat) {
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

                        VStack {
                            Text("•eRCli•© v" + appVersion!)
                                .font(.title3)
                                .foregroundColor(.white)
                            Spacer()
                            Text("All rights reserved")
                                .font(.footnote)
                                .foregroundColor(.white)
                        }.frame(height: 80).padding([.leading, .trailing], 15)
                        
                        SettingsDevider()
                    }
                }.background(Color.blue.opacity(0.2))
                                
                Spacer()
            }
        }.gesture(getDragGesture(gestures: [DragDirection.RIGHT: checkChanges]))
            .alert(isPresented: $isChanged) {
                SettingsAlert(leaveAction: viewModel.check, saveAction: updateSettings).showAlert()
            }
    }

    // We should set the device code from QR-code scan
    func setDeviceCode(deviceCode: String) {
        self.deviceCode.value = deviceCode
    }
    
    func checkChanges() {
        if (session.deviceSettings.deviceCode != (Int64(deviceCode.value) ?? -1)
            || session.deviceSettings.unitNumber != (Int64(unitNumber.value) ?? 5)
            || session.deviceSettings.isFahrenheit != (temperatureUnitIndex == 1)
            || session.deviceSettings.dateSeparator != dateSeparator.value
            || session.deviceSettings.timeSeparator != timeSeparator.value
            || session.deviceSettings.timeFormat != is24
            || session.deviceSettings.dateFormat != dateFormat) {
            isChanged = true
        }
        if (!isChanged) {
            viewModel.check()
        }
    }
    
    func updateSettings() {
        session.deviceSettings.deviceCode = Int64(deviceCode.value) ?? -1
        session.deviceSettings.unitNumber = Int64(unitNumber.value) ?? 5
        session.deviceSettings.isFahrenheit = temperatureUnitIndex == 1
        session.deviceSettings.dateSeparator = dateSeparator.value
        session.deviceSettings.timeSeparator = timeSeparator.value
        session.deviceSettings.timeFormat = is24
        session.deviceSettings.dateFormat = dateFormat
        
        viewModel.check()
    }

}

struct SettingsAlert {
    private var leaveAction: () -> Void
    private var saveAction: () -> Void
    
    init(leaveAction: @escaping () -> Void, saveAction: @escaping() -> Void) {
        self.leaveAction = leaveAction
        self.saveAction = saveAction
    }
    
    public func showAlert() -> Alert {
        return Alert(
            title: Text("Are you sure you want to leave the page?"),
            message: Text("There are changes in settings"),
            primaryButton: .destructive(Text("Leave")) {
                leaveAction()
            },
            secondaryButton: .destructive(Text("Save")) {
                saveAction()
            }
        )
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
