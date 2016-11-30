//  Copyright © 2016 Gavan Chan. All rights reserved.

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

final class WeatherClient {

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

  var metric: Metric = .celsius

  func weather(for cityID: City.Identifier) -> Observable<Weather> {
    return .empty()
  }

}
