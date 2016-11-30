//  Copyright © 2016 Gavan Chan. All rights reserved.

import Argo
import Foundation
import RxCocoa
import RxSwift

fileprivate let cities: Array<City> = [
  (7839805, "Melbourne"),
  (2147714, "Sydney"),
  (2063523, "Perth"),
  (2078025, "Adelaide"),
  (7839562, "Brisbane"),
  (2163355, "Hobart"),
  (7839402, "Darwin"),
].map(City.init)

final class WeatherClient: ClientProtocol {

  enum Metric {
    case celsius
    case fahrenheit
    case kelvin

    var requestParameter: String? {
      let value: String?
      switch self {
      case .celsius: value = "metric"
      case .fahrenheit: value = "imperial"
      case .kelvin: value = nil
      }
      return value.flatMap { "units=\($0)" }
    }
  }

  enum Endpoint: String {
    case weather = "weather"
  }

  let session: URLSession = .shared
  var base: URL { return URL(string: baseURL)! }

  private let baseURL: String = "http://api.openweathermap.org/data/2.5"

  var metric: Metric = .celsius

  func weather(for cityID: City.Identifier) -> Observable<Weather> {
    let query: Dictionary<String, String> = [
      "id": "7839805",
      "APPID": "402c2de16506bb59c7a6afc8b60778c2",
      "units": "metric",
    ]
    let weather: Observable<Weather> = json(for: .weather, via: .get, withQuery: query)
      .map(Weather.decode)
      .map { $0.value! }

    return weather
  }

}
