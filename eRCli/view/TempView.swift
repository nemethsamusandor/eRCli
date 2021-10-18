//
//  TempView.swift
//  rTemp
//
//  Created by Németh Sándor on 2021. 10. 12..
//

import SwiftUI

struct TempView: View {
    
    var temperature: Double?
    var humidity: Double?
    var date: String?
    
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 10) {
                HeaderView(title: "ROOM CLIMATE")
                RefreshableScrollView (onRefresh: { done in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        viewModel.check()
                    }
                  })
                {
                    VStack {
                        ZStack {
                            Text(getFormattedDate())
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(20)
                            
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity, maxHeight: 30, alignment: .trailing)
                                .foregroundColor(.white)
                                .onTapGesture {
                                    viewModel.settings()
                                }
                                .padding(.trailing, 10)
                        }
                        StatusComponentView(imageName: "temperature",
                                            value: getDoubleString(value: handleFahrenheit(value: temperature)),
                                            valueSign: (Session().deviceSettings.isFahrenheit ? ValueSign.fahrenheit : ValueSign.celsius))
                    
                        StatusComponentView(imageName: "humidity",
                                            value: getDoubleString(value: humidity),
                                            valueSign: ValueSign.percentage)
                        
                        Text("Pull down to refresh")
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(20)
                        
                    }
                }.gesture(getDragGesture(dragDirection: DragDirection.LEFT, action: viewModel.settings))
            }
        }
    }
    
    private func getDoubleString(value: Double?) -> String {
        guard let checkedValue = value else {
            return "--.-"
        }
        return String(format: "%.1f", checkedValue)
    }
    
    func handleFahrenheit(value: Double?) -> Double? {
        guard let checkedValue = value else {
            return value
        }
        return Session().deviceSettings.isFahrenheit ? (checkedValue * 9/5) + 32 : checkedValue
    }
    
    func getFormattedDate() -> String {
        guard let dateValue = self.date else {
            return "------"
        }
        
        let deviceSettings = Session().deviceSettings
        let dateSep = deviceSettings.dateSeparator
        let timeSep = deviceSettings.timeSeparator
        
        let dateFormatter = DateFormatter()
        var pattern : String
        
        switch deviceSettings.dateFormat {
        case .DMY:
            pattern = "dd\(dateSep)MM\(dateSep)yyyy"
        case .MDY:
            pattern = "MM\(dateSep)dd\(dateSep)yyyy"
        case .YMD:
            pattern = "yyyy\(dateSep)MM\(dateSep)dd"
        }
        
        pattern += " " + (deviceSettings.timeFormat ? "HH" : "hh") + timeSep + "mm\(timeSep)ss" + (deviceSettings.timeFormat ? "" : "a")
        
        dateFormatter.dateFormat = pattern
        dateFormatter.timeZone = NSTimeZone(abbreviation: "GMT+0:00") as TimeZone?
            
        let inDateFormatter = ISO8601DateFormatter()
        
        guard let inDate = inDateFormatter.date(from: dateValue + "Z") else {
            return "------"
        }
        
        return dateFormatter.string(from: inDate)
    }
}
