//
//  Network.swift
//  uNetwork
//
//  Created by Luís Marques Silva on 16/10/2020.
//
//  Adapted from Point-Free Search Example (https://github.com/pointfreeco/swift-composable-architecture/tree/main/Examples/Search)
//

import Foundation
import ComposableArchitecture
import uCore

// MARK: - API models
public struct Location: Decodable, Equatable {
    public var id: Int
    public var title: String
}

public struct LocationWeather: Decodable, Equatable {
    public var consolidatedWeather: [ConsolidatedWeather]
    public var id: Int

    public struct ConsolidatedWeather: Decodable, Equatable {
        public var applicableDate: Date
        public var theTemp: Double
    }
}

// MARK: - API client interface
// Typically this interface would live in its own module, separate from the live implementation.
// This allows the search feature to compile faster since it only depends on the interface.
public struct WeatherClient {
    public var weather: (Int) -> Effect<LocationWeather, Failure>

    public struct Failure: Error, Equatable {}
}

// MARK: - Live API implementation
// Example endpoints:
//   https://www.metaweather.com/api/location/search/?query=san
//   https://www.metaweather.com/api/location/2487956/
extension WeatherClient {
    public static let live = WeatherClient(
        weather: { id in
            let url = URL(string: "https://www.metaweather.com/api/location/\(id)/")!

            return URLSession.shared.dataTaskPublisher(for: url)
                .map { data, _ in data }
                .decode(type: LocationWeather.self, decoder: jsonDecoder)
                .mapError { _ in Failure() }
                .eraseToEffect()
        })
}

// MARK: - Mock API implementations
extension WeatherClient {
    public static func mock(
        weather: @escaping (Int) -> Effect<LocationWeather, Failure> = { _ in fatalError("Unmocked") }
    ) -> Self {
        Self(
            weather: weather
        )
    }
}

// MARK: - Private helpers
private let jsonDecoder: JSONDecoder = {
    let d = JSONDecoder()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    d.dateDecodingStrategy = .formatted(formatter)
    return d
}()

extension Location {
    private enum CodingKeys: String, CodingKey {
        case id = "woeid"
        case title
    }
}

extension LocationWeather {
    private enum CodingKeys: String, CodingKey {
        case consolidatedWeather = "consolidated_weather"
        case id = "woeid"
    }
}

extension LocationWeather.ConsolidatedWeather {
    private enum CodingKeys: String, CodingKey {
        case applicableDate = "applicable_date"
        case theTemp = "the_temp"
    }
}
