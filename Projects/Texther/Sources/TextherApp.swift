//
//  TextherApp.swift
//  Texther
//
//  Created by Luís Marques Silva on 16/10/2020.
//
//  Based on Point-Free Search Example (https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/Search)
//

import SwiftUI
import ComposableArchitecture
import uHome
import uNetwork

@main
struct TextherApp: App {
    var body: some Scene {
        WindowGroup {
            #if os(macOS)
            EmptyView()
            #else
            NavigationView {
                HomeView(
                    store: Store(
                        initialState: HomeState(),
                        reducer: homeReducer.debug(),
                        environment: HomeEnvironment(
                            weatherClient: WeatherClient.live,
                            mainQueue: DispatchQueue.main.eraseToAnyScheduler()
                        )
                    )
                )
            }
            #endif
        }
    }
}
