//
//  HomeView.swift
//  uHome
//
//  Created by Luís Marques Silva on 16/10/2020.
//
//  Adapted from Point-Free Search Example (https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/Search)
//

import SwiftUI
import ComposableArchitecture
import uNetwork

public struct HomeState: Equatable {
    public init() {}

    var locationWeather: LocationWeather?
    var locationWeatherRequestInFlight: Int?
    var searchQuery = ""
}

public enum HomeAction: Equatable {
    case fetchForecast(Int)
    case locationWeatherResponse(Result<LocationWeather, WeatherClient.Failure>)
}

public struct HomeEnvironment {
    public init(weatherClient: WeatherClient, mainQueue: AnySchedulerOf<DispatchQueue>) {
        self.weatherClient = weatherClient
        self.mainQueue = mainQueue
    }

    public var weatherClient: WeatherClient
    public var mainQueue: AnySchedulerOf<DispatchQueue>
}

// MARK: - Search feature reducer
public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment> {
    state, action, environment in
    switch action {
    case let .fetchForecast(locationId):
        struct SearchWeatherId: Hashable {}

        state.locationWeatherRequestInFlight = locationId

        return environment.weatherClient
            .weather(locationId)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map(HomeAction.locationWeatherResponse)
            .cancellable(id: SearchWeatherId(), cancelInFlight: true)

    case let .locationWeatherResponse(.failure(locationWeather)):
        state.locationWeather = nil
        state.locationWeatherRequestInFlight = nil
        return .none

    case let .locationWeatherResponse(.success(locationWeather)):
        state.locationWeather = locationWeather
        state.locationWeatherRequestInFlight = nil
        return .none
    }
}

// MARK: - Search feature view
public struct HomeView: View {
    let store: Store<HomeState, HomeAction>

    public init(store: Store<HomeState, HomeAction>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store) { viewStore in
            VStack {
                Text("Lisbon")
                    .font(Font.system(size: 50))

                if let temp = viewStore.locationWeather?.consolidatedWeather.first?.theTemp {
                    Text("\(Int(temp))º")
                        .font(Font.system(size: 100))
                }
                else {
                    Text("--")
                }

                Spacer()
            }
            .onAppear {
                viewStore.send(.fetchForecast(742676))
            }
        }
    }
}
