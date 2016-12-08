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

  func weather(for cityID: City.Identifier, in unit: UnitTemperature = .celsius) -> Observable<Weather> {
    let matchingCityID: ((City) -> Bool) = { $0.identifier == cityID }

    let city: City

    if let _city = WeatherClientStub.cities.first(where: matchingCityID) {
      city = _city
    } else {
      city = City(identifier: 10, name: "Unknown City")
    }

    return Observable<Weather>.create { observer in
      DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
        let seed: Double = Double(city.identifier)
        let temperature: Measurement<UnitTemperature> = Measurement(value: seed.remainder(dividingBy: 14.0) + 14.0, unit: .celsius)

        let data: Weather = Weather(city: city, current: temperature.converted(to: unit).value, cloudiness: seed.remainder(dividingBy: 94.0))

        observer.onNext(data)
        observer.onCompleted()
      }
      return Disposables.create()
    }
  }

  private init() { }

}

import Foundation
import RxSwift
