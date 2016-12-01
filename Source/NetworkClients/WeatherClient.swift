//  Copyright © 2016 Gavan Chan. All rights reserved.

import Argo
import Foundation
import RxCocoa
import RxSwift

typealias WeatherProvidingClient = ClientProtocol & WeatherProviding

final class WeatherClient: WeatherProvidingClient {

  enum Endpoint: String {
    case weather = "weather"
  }

  let session: URLSession = .shared
  var base: URL { return URL(string: baseURL)! }

  private let baseURL: String = "http://api.openweathermap.org/data/2.5"

  func weather(for cityID: City.Identifier, in unit: UnitTemperature = .celsius) -> Observable<Weather> {
    var query: Dictionary<String, String> = [
      "id": String(reflecting: cityID),
    ]
    if let unit = unit.requestParameter { query.updateValue(unit, forKey: "units") }

    let weather: Observable<Weather> = json(for: .weather, via: .get, withQuery: query)
      .map(Weather.decode)
      .flatMap { Observable<Weather>.from(decoded: $0) }

    return weather
  }

}

fileprivate extension UnitTemperature {
  var requestParameter: String? {
    switch self {
    case UnitTemperature.celsius: return "metric"
    case UnitTemperature.fahrenheit: return "imperial"
    case UnitTemperature.kelvin: return nil
    default: return nil
    }
  }
}
