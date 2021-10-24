//
//  ContentView.swift
//
//  Created by Sándor Németh on 2021.10.11.
//  Copyright © 2021 Sándor Németh. All rights reserved.
//

import CodeScanner

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = ContentViewModel()
    
    var body: some View {
        switch viewModel.state {
            case .idle:
                StartView().onAppear(perform: viewModel.check)
            case .loading:
                LoadingView()
            case .settings:
                SettingsView(viewModel: self.viewModel)
            case .failed(let error):
                ErrorView(error: error, retryHandler: viewModel.check, settingsHandler: viewModel.settings)
            case .loaded(let indoor):
                TempView(temperature: indoor.temperature, humidity: indoor.humidity, date: indoor.timestamp, viewModel: self.viewModel)
            case .scanQR:
                CodeScannerView(codeTypes: [.qr],
                                showViewfinder: true,
                                simulatedData: "http://install.egain.se?id=94001404",
                                completion: self.handleScan)
            case .setCode(let code):
                SettingsView(viewModel: self.viewModel, code: code)
        }
    }
        
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        viewModel.settings()

        /**
            Valid format is http://install.egain.se?id=94001403
         */
        switch result {
            case .success(let code):
                let details = code.components(separatedBy: "?")
                guard details.count == 2 else {
                    viewModel.error(error: AppError(code: .qrCodeNotValid, message: "Scanned QR code cannot be processed"))
                    return
                }
                
                let id = details[1].components(separatedBy: "=")
                guard id.count == 2 else {
                    viewModel.error(error: AppError(code: .qrCodeNotValid, message: "Scanned QR code cannot be processed"))
                    return
                }
                
                viewModel.setCode(code: Int64(id[1]) ?? -1)
            case .failure(let error):
                viewModel.error(error: AppError(code: .scanError, message: error.localizedDescription))
        }
    }
}

func getDragGesture(gestures: [DragDirection : () -> Void]) -> _EndedGesture<DragGesture> {
    return DragGesture(coordinateSpace: .local)
                .onEnded {value in
                    withAnimation() {
                        var actDragDirection: DragDirection
                        
                        if (abs(value.translation.width) > abs(value.translation.height)) {
                            actDragDirection = value.translation.width > 0 ? DragDirection.RIGHT : DragDirection.LEFT
                        }
                        else {
                            actDragDirection = value.translation.height > 0 ? DragDirection.UP : DragDirection.DOWN
                        }
                        
                        if (gestures.keys.contains(actDragDirection)) {
                            gestures[actDragDirection]!()
                        }
                        
                    }
                }
}

struct BackgroundView: View {
    var body: some View {
        Color.white.edgesIgnoringSafeArea(.all)
        LinearGradient(gradient: Gradient(colors: [.blue, Color.init("TopColor"), Color.init("Background")]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}

struct HeaderView: View {
    let ratio = getRatio()
    
    var title: String
    
    var body: some View {
        HStack(alignment: .bottom) {
            HStack (alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                Text("•eRCli• for")
                    .lineSpacing(0)
                    .font(.system(size: 10*ratio, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.leading, 15*ratio)
            }
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 40*ratio, alignment: .leading)
                .foregroundColor(.white)
            Spacer()
            Text(title)
                .font(.title2)
                .foregroundColor(.white)
                .padding(.trailing, 15*ratio)
        }
        Divider()
            .frame(height: 2)
            .background(Color.white)

    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            ProgressView("Loading....")
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 180, height: 180, alignment: .center)
            VStack {
                HeaderView(title: "")
                Spacer()
            }
        }
    }
}

struct StartView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                HeaderView(title: "")
                Spacer()
            }
        }
    }
}

struct StatusComponentView: View {
    let ratio = getRatio()
    
    var imageName: String
    var value: String
    var valueSign: ValueSign
    
    var body: some View {
        VStack(spacing: 10*ratio) {
            Image(imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:180*ratio, height: 180*ratio)
            
            Text(value + valueSign.rawValue)
                .font(.system(size: 60*ratio, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.bottom, 40*ratio)
    }
}

func getRatio() -> CGFloat {
    let refHeight: CGFloat = 926 // iPhone 12 Pro max height
    let screenSize: CGRect = UIScreen.main.bounds

    let maxSize: CGFloat = screenSize.height > screenSize.width ? screenSize.height : screenSize.width
    return maxSize/refHeight
}

enum ValueSign: String {
    case percentage = " %rH"
    case celsius = " C°"
    case fahrenheit = " F°"
}

enum DragDirection {
    case LEFT
    case RIGHT
    case UP
    case DOWN
}
