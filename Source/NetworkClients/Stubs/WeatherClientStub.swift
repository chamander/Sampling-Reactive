//  Copyright © 2016 Gavan Chan. All rights reserved.

final class WeatherClientStub: WeatherProviding {

  static let shared: WeatherClientStub = .init()

  fileprivate static let cities: Array<City> = [
    (7839805, "Melbourne"),
    (2147714, "Sydney"),
    (2063523, "Perth"),
    (2078025, "Adelaide"),
    (7839562, "Brisbane"),
    (2163355, "Hobart"),
    (7839402, "Darwin"),
  ].map(City.init)

  func weather(for cityID: City.Identifier, in metric: UnitTemperature) -> Observable<Weather> {
    let matchingCityID: ((City) -> Bool) = { $0.identifier == cityID }

    guard let city = WeatherClientStub.cities.first(where: matchingCityID) else {
      return Observable<Weather>.create { observer in
        DispatchQueue.global(qos: .default).asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 2000000)) {
          observer.onNext(WeatherClientStub.dummyWeatherData(for: metric))
          observer.onCompleted()
        }
        return Disposables.create()
      }
    }

    return .empty()
  }

  private static func dummyWeatherData(for unit: UnitTemperature) -> Weather {
    let city: City = City(identifier: 0, name: "Unknown City")

    let temperature: Temperature
    switch unit {
    case UnitTemperature.celsius: temperature = 24.0
    case UnitTemperature.fahrenheit: temperature = 75.2
    case UnitTemperature.kelvin: temperature = 273.15
    default: temperature = 0.0
    }

    let cloudiness: Percentage = 50.0

    return Weather(city: city, current: temperature, cloudiness: cloudiness)
  }

  private init() { }

}

import Foundation
import RxSwift
