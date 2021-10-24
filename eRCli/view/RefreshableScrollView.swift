//
//  RefreshableScrollView.swift
//
//  Created by Sándor Németh on 2021.10.17.
//  Copyright © 2021 Sándor Németh. All rights reserved.
//

import SwiftUI

private enum PositionType {
  case fixed, moving
}

private struct Position: Equatable {
  let type: PositionType
  let y: CGFloat
}

private struct PositionPreferenceKey: PreferenceKey {
  typealias Value = [Position]

  static var defaultValue = [Position]()

  static func reduce(value: inout [Position], nextValue: () -> [Position]) {
    value.append(contentsOf: nextValue())
  }
}

private struct PositionIndicator: View {
  let type: PositionType

  var body: some View {
    GeometryReader { proxy in
        Color.clear
          .preference(key: PositionPreferenceKey.self, value: [Position(type: type, y: proxy.frame(in: .global).minY)])
     }
  }
}

typealias RefreshComplete = () -> Void
typealias OnRefresh = (@escaping RefreshComplete) -> Void

private let THRESHOLD: CGFloat = 50

private enum RefreshState {
  case waiting, primed, loading
}

struct RefreshableScrollView<Content: View>: View {
  let onRefresh: OnRefresh
  let content: Content

  @State private var state = RefreshState.waiting

  init(onRefresh: @escaping OnRefresh, @ViewBuilder content: () -> Content) {
    self.onRefresh = onRefresh
    self.content = content()
  }

  var body: some View {
    ScrollView {
      ZStack(alignment: .top) {
        PositionIndicator(type: .moving)
          .frame(height: 0)

         content
           .alignmentGuide(.top, computeValue: { _ in
             (state == .loading) ? -THRESHOLD : 0
            })

          ZStack {
            Rectangle()
              .foregroundColor(.clear)
              .frame(height: THRESHOLD)
            ProgressView("")
                .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
          }.offset(y: (state == .loading) ? 0 : -THRESHOLD)
        }
      }
      .background(PositionIndicator(type: .fixed))
      .onPreferenceChange(PositionPreferenceKey.self) { values in
        if state != .loading {
          DispatchQueue.main.async {
            let movingY = values.first { $0.type == .moving }?.y ?? 0
            let fixedY = values.first { $0.type == .fixed }?.y ?? 0
            let offset = movingY - fixedY

            if offset > THRESHOLD && state == .waiting {
              state = .primed

            } else if offset < THRESHOLD && state == .primed {
              state = .loading
              onRefresh {
                withAnimation {
                  self.state = .waiting
                }
              }
            }
          }
        }
      }
  }
}
