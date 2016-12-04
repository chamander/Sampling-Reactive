//  Copyright © 2016 Gavan Chan. All rights reserved.

struct WeatherViewModel {

  private let data: Weather

  init(with data: Weather) {
    self.data = data
  }

  var location: City.Name { return data.city.name }

  var information: String { return String(format: "Current: %.1fºC", data.current) }

  var theme: WeatherView.Theme! {
    switch data.current {
    case let x where x >= 35.0: return .blistering
    case 25.0 ..< 35.0: return .hot
    case 18.0 ..< 25.0: return .neutral
    case let x where x < 18.0: return .cold
    default: return nil // This case should not be reached.
    }
  }

}
